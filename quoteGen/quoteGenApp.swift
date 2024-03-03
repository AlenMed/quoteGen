//
//  quoteGenApp.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import SwiftUI
import SwiftData

@main
struct quoteGenApp: App {
    @State var netService = NetworkService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(netService: netService)
        }
        .modelContainer(sharedModelContainer)
    }
}
