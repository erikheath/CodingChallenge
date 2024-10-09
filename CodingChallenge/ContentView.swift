//
//  ContentView.swift
//  CodingChallenge
//
//  Created by Erik Heath Thomas on 9/30/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Product.productName) private var products: [Product]

    var body: some View {
        NavigationView {
            List {
                ForEach(products) { product in
                    NavigationLink {
                        DetailView(product: product)
                    } label: {
                        AsyncImage(url: product.courseImageURL) { image in
                            image.image?.resizable().aspectRatio(120/200, contentMode: .fit)
                        }
                        .frame(width: 120, height: 200, alignment: .leading)
                        
                        Text(product.productName)
                    }
                }
            }
        }
        .task {
            do {
                let url = URL(string: "https://tgc-stg-m2-apps.s3.amazonaws.com/ioschallenge/homeitems/index.json")!
                try await Product.configure(using: url, for: modelContext)
            } catch {
                
            }
        }
    }

}
