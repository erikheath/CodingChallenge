//
//  Product.swift
//  CodingChallenge
//
//  Created by Erik Heath Thomas on 9/30/24.
//

import SwiftUI
import SwiftData

@Model
public final class Product: DecodableWithConfiguration {
    
    @Attribute(.unique)
    public var courseID: Int
    
    public var productName: String
    
    public var productShortDescription: String
    
    public var courseImageName: String
    
    public var courseImageURL: URL
    
    @Relationship
    public var lectures: [Lecture]
    
    public struct DecoderConfiguration {
        let context: ModelContext
    }
    
    enum CodingKeys: String, CodingKey {
        case courseID = "course_id"
        case productName = "product_name"
        case productShortDescription = "product_short_description"
        case courseImageName = "course_Image_Name"
        case lectures = "lectures"
    }
    
    public init(from decoder: any Decoder, configuration: DecoderConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        func url<T: CodingKey>(for key: T, in container: KeyedDecodingContainer<T>) throws -> URL? {
            guard let urlComponent = try container.decodeIfPresent(Int.self, forKey: key)
            else { return nil }
            let urlString = "https://secureimages.teach12.com/tgc/images/m2/wondrium/courses/\(urlComponent)/portrait/\(urlComponent).jpg"
            return URL(string: urlString)
        }
        
        // Required Elements when initializing a Product Object
        self.courseID = try container.decodeIfPresent(Int.self, forKey: .courseID) ?? 0
        self.productName = try container.decodeIfPresent(String.self, forKey: .productName) ?? ""
        self.productShortDescription = try container.decodeIfPresent(String.self, forKey: .productShortDescription) ?? ""
        self.courseImageName = try container.decodeIfPresent(String.self, forKey: .courseImageName) ?? ""
        self.courseImageURL = try url(for: CodingKeys.courseID, in: container)!
        
        // Relationship Elements when initializing a Product Object
        let decoderConfiguration = Lecture.DecoderConfiguration.init(context: configuration.context)
        self.lectures = try container.decodeIfPresent([Lecture].self, forKey: .lectures, configuration: decoderConfiguration) ?? [Lecture]()
    }
    
    public init(courseID: Int, productName: String, productShortDescription: String, courseImageName: String, courseImageURL: URL, lectures: [Lecture]) {
        self.courseID = courseID
        self.productName = productName
        self.productShortDescription = productShortDescription
        self.courseImageName = courseImageName
        self.courseImageURL = courseImageURL
        self.lectures = lectures
    }
    
    @MainActor
    public class func configure(using url: URL, for context: ModelContext) async throws {
       
        let descriptor = FetchDescriptor<Product>()
        guard try context.fetchCount(descriptor) ==  0
        else {
          // Data already fetched.
            return
        }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let HTTPResponse = response as? HTTPURLResponse
        else {
            throw ErrorReport(userPresentableTitle: "Received unexpected response type from service", userPresentableSubtitle: nil, debugDescription: "Response type is not HTTPURLResponse", errorCode: nil, screenName: nil, market: nil, sourceName: nil)
        }
        
        guard 200..<300 ~= HTTPResponse.statusCode
        else {
            print(HTTPResponse.allHeaderFields)
            print(HTTPResponse.statusCode)
            print(HTTPResponse.url?.absoluteString)
            print(String(data: data, encoding: .utf8))
            throw ErrorReport(userPresentableTitle: "Unexpected response code from service", userPresentableSubtitle: nil, debugDescription: "Response code was not within the 200 to 299 boundary", errorCode: nil, screenName: nil, market: nil, sourceName: nil)
        }
        
        let decoderConfiguration = ProductEnvelope.DecoderConfiguration.init(context: context)
        let productEnvelope = try JSONDecoder().decode(ProductEnvelope.self, from: data, configuration: decoderConfiguration)
        productEnvelope.products.forEach { product in
            context.insert(product)
        }
        try context.save()
    }
    
    @MainActor
    public class func productDetails(for product: Product, using url: URL, in context: ModelContext) async throws {
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let HTTPResponse = response as? HTTPURLResponse
        else {
            throw ErrorReport(userPresentableTitle: "Received unexpected response type from service", userPresentableSubtitle: nil, debugDescription: "Response type is not HTTPURLResponse", errorCode: nil, screenName: nil, market: nil, sourceName: nil)
        }
        
        guard 200..<300 ~= HTTPResponse.statusCode
        else {
            print(HTTPResponse.allHeaderFields)
            print(HTTPResponse.statusCode)
            print(HTTPResponse.url?.absoluteString)
            print(String(data: data, encoding: .utf8))
            throw ErrorReport(userPresentableTitle: "Unexpected response code from service", userPresentableSubtitle: nil, debugDescription: "Response code was not within the 200 to 299 boundary", errorCode: nil, screenName: nil, market: nil, sourceName: nil)
        }
        
        let decoderConfiguration = Product.DecoderConfiguration.init(context: context)
        let productDetail = try JSONDecoder().decode(Product.self, from: data, configuration: decoderConfiguration)
        // Ideally, this would write to the correct product, but since there is only one
        // details list, it will need to be manually merged into any product that is selected.
        productDetail.lectures.forEach { lecture in
            product.lectures.append(lecture)
        }
        
        try context.save()
    }
    
}

public final class ProductEnvelope: DecodableWithConfiguration {
    
    public var products: [Product]
    
    public struct DecoderConfiguration {
        let context: ModelContext
    }
    
    enum CodingKeys: String, CodingKey {
        case products = "products"
    }
    
    public init(from decoder: any Decoder, configuration: DecoderConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.products = try container.decode([Product].self, forKey: .products, configuration: Product.DecoderConfiguration.init(context: configuration.context))
    }
    
}

struct ErrorReport: Error {
    let userPresentableTitle: String?
    let userPresentableSubtitle: String?
    let debugDescription: String?
    let errorCode: Int?
    let screenName: String?
    let market: String?
    let sourceName: String?
}
