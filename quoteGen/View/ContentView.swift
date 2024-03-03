//
//  ContentView.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import SwiftUI

struct ContentView: View {
    @State var netService: NetworkService
    
    @State private var selection: Int = 1
    var body: some View {
        TabView(selection: $selection) {
            
            QuoteView(netService: netService)
                .tabItem {
                    Image(systemName: "quote.bubble.fill")
                }
            QuoteListView(netService: netService)
                .tabItem {
                    Image(systemName: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView(netService: NetworkService())
}
