//
//  DetailView.swift
//  CodingChallenge
//
//  Created by Erik Heath Thomas on 9/30/24.
//

import SwiftUI
import SwiftData
import AVKit

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var product: Product
    @State private var playVideo: Bool = false
    @State private var player = AVPlayer()
    @State private var currentLecture: Lecture?
    
    
    var body: some View {
        List {
            ForEach(product.lectures.sorted(using: SortDescriptor(\Lecture.lectureSKU))) { lecture in
                Button {
                    setupPlayer(url: lecture.lectureHLSURL)
                    player.play()
                    playVideo = true
                } label: {
                    HStack {
                        AsyncImage(url: product.courseImageURL) {
                            image in
                            image.image?.resizable().aspectRatio(60/100, contentMode: .fit)
                        }
                        .frame(width: 60, height: 100, alignment: .leading)
                        
                        Text(lecture.lectureName)
                    }
                }
            }
        }
        .sheet(isPresented: $playVideo, onDismiss: {
            
        }, content: {
            VideoPlayer(player: player)
                .ignoresSafeArea()
        })
        .task {
            do {
                let url = URL(string: "https://tgc-stg-m2-apps.s3.amazonaws.com/ioschallenge/details/index.json")!
                try await Product.productDetails(for: product, using: url, in: modelContext)
            } catch {
                
            }
        }
    }
    
    func setupPlayer(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
}

