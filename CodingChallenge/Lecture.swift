//
//  Lecture.swift
//  CodingChallenge
//
//  Created by Erik Heath Thomas on 9/30/24.
//

import SwiftData
import SwiftUI

@Model
public final class Lecture: DecodableWithConfiguration {
    
    @Attribute(.unique)
    public var lectureSKU: String
    
    public var lectureName: String
    
    public var lectureImageFilename: String
    
    public var lectureImageURL: URL? = nil
    
    public var lectureHLSURL = URL(string: "https://cdn.flowplayer.com/a30bd6bc-f98b-47bc-abf5-97633d4faea0/hls/de3f6ca7-2db3-4689-8160-0f574a5996ad/playlist.m3u8")!
    
    public var lectureMP4URL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    
    public var lectureAlternateMP4URL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!
        
    public struct DecoderConfiguration {
        let context: ModelContext
    }
    
    enum CodingKeys: String, CodingKey {
        case lectureSKU = "lecture_sku"
        case lectureName = "lecture_name"
        case lectureImageFilename = "lecture_image_filename"
    }
    
    public init(from decoder: any Decoder, configuration: DecoderConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        func url<T: CodingKey>(for key: T, in container: KeyedDecodingContainer<T>) throws -> URL? {
            guard let urlComponent = try container.decodeIfPresent(String.self, forKey: key)
            else { return nil }
            let urlString = "https://secureimages.teach12.com/tgc/images/m2/wondrium/courses/\(urlComponent)/portrait/\(urlComponent).jpg"
            return URL(string: urlString)
        }
        
        // Required Elements when initializing a Product Object
        self.lectureSKU = try container.decode(String.self, forKey: .lectureSKU)
        self.lectureName = try container.decode(String.self, forKey: .lectureName)
        self.lectureImageFilename = try container.decode(String.self, forKey: .lectureImageFilename)
        
        self.lectureImageURL = try url(for: CodingKeys.lectureSKU, in: container)
    }
    
    init(lectureSKU: String, lectureName: String, lectureImageFilename: String, lectureHLSURL: URL, lectureMP4URL: URL, lectureAlternateMP4URL: URL) {
        self.lectureSKU = lectureSKU
        self.lectureName = lectureName
        self.lectureImageFilename = lectureImageFilename
        self.lectureHLSURL = lectureHLSURL
        self.lectureMP4URL = lectureMP4URL
        self.lectureAlternateMP4URL = lectureAlternateMP4URL
    }
    
}

public final class LectureEnvelope: DecodableWithConfiguration {
    
    public var lectures: [Lecture]
    
    public struct DecoderConfiguration {
        let context: ModelContext
    }
    
    enum CodingKeys: String, CodingKey {
        case lectures = "lectures"
    }
    
    public init(from decoder: any Decoder, configuration: DecoderConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decoderConfiguraton = Lecture.DecoderConfiguration.init(context: configuration.context)
        self.lectures = try container.decodeIfPresent([Lecture].self, forKey: .lectures, configuration: decoderConfiguraton) ?? []
    }
    
    public init(lectures: [Lecture]) {
        self.lectures = lectures
    }
}
