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
            .searchable(text: $searchText, prompt: Text("Search by author or quote."))
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
    QuoteListView()
}

struct QuoteDetailView: View {
    let quote: Quote
    
    @State private var errorMessage: String = ""
    @State private var authorImage: UIImage?
    
    var body: some View {
        VStack {
            if let authorImage = authorImage {
                Image(uiImage: authorImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .clipShape(.rect(cornerRadius: 8))
            }
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
            .onAppear {
                downloadAndSetAuthorImage(from: quote.image ?? "")
            }
        }
        .padding(12)
    }
    private func downloadAndSetAuthorImage(from imageURLString: String) {
        guard let imageUrl = URL(string: imageURLString) else {
            errorMessage = "Invalid image URL"
            return
        }
        
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // Update the authorImage state variable on the main thread
            DispatchQueue.main.async {
                withAnimation { authorImage = UIImage(data: data) }
            }
        }.resume()
    }
}
