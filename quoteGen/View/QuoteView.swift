//
//  ContentView.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import SwiftUI

struct QuoteView: View {
    @Environment(\.modelContext) private var modelContext
    @State var netService: NetworkService
    
    @State private var author: String = ""
    @State private var quote: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(quote)
                    .fontWeight(.semibold)
                    .font(.title2)
                Text("- \(author)")
                    .fontWeight(.light)
                    .font(.caption)
            }
            Spacer()
            
            Button("Fetch a Quote") {
                 fetch()
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .padding(.bottom, 42)
        }
        .padding(12)
    }
    private func fetch() {
        errorMessage = ""
        netService.getApiData() { result in
            switch result {
            case .success(let quoteData):
                
                withAnimation { quote = quoteData.quote }
                withAnimation { author = quoteData.author }
                
                let logQuote = Quote(quote: quoteData.quote, author: quoteData.author, timestamp: Date())
                withAnimation { modelContext.insert(logQuote) }
                
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    QuoteView(netService: NetworkService())
}
