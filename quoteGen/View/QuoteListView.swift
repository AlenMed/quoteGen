//
//  QuoteListView.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import SwiftUI
import SwiftData

struct QuoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var quotes: [Quote]
    @State var netService: NetworkService
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(quotes.filter { quote in
                    searchText.isEmpty ||
                    quote.quote.localizedCaseInsensitiveContains(searchText) ||
                    quote.author.localizedCaseInsensitiveContains(searchText)
                }, id: \.self) { quote in
                    
                    NavigationLink {
                        QuoteDetailView(quote: quote)
                    } label: {
                        HStack(alignment: .bottom) {
                            Text(quote.quote)
                                .lineLimit(2)
                            Spacer()
                            Text(quote.author)
                                .font(.footnote)
                                .fontWeight(.ultraLight)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Quotes")
            .searchable(text: $searchText, prompt: Text("Search by Quote or Author."))
        }
    }
    private func deleteItems(offsets: IndexSet) {
            withAnimation {
                for index in offsets {
                    modelContext.delete(quotes[index])
                }
            }
        }
}

#Preview {
    QuoteListView(netService: NetworkService())
}

struct QuoteDetailView: View {
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(quote.quote)
                .font(.title2)
                .fontWeight(.semibold)
            Text("- \(quote.author)")
                .font(.footnote)
            Text("Saved at: \(DateFormatter.localizedString(from: quote.timestamp, dateStyle: .medium, timeStyle: .short))")
                .padding(.top)
                .fontWeight(.ultraLight)
                .font(.system(size: 8))
        }
    }
}
