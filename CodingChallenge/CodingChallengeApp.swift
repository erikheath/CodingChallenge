//
//  CodingChallengeApp.swift
//  CodingChallenge
//
//  Created by Erik Heath Thomas on 9/30/24.
//

import SwiftUI
import SwiftData

@main
struct CodingChallengeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Product.self, Lecture.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
