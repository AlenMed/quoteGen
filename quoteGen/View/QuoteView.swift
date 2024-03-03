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
    @State private var authorImage: UIImage?
    
    @State private var errorMessage: String = ""
    
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
        netService.getQuote { result in
            switch result {
            case .success(let quoteData):
                withAnimation { quote = quoteData.quote }
                withAnimation { author = quoteData.author }
                fetchAuthorImageAndUpdateModel(author: quoteData.author, quote: quoteData.quote)
            case .failure(let error):
                handleFetchError(error: error)
            }
        }
    }
    private func fetchAuthorImageAndUpdateModel(author: String, quote: String) {
        netService.getAuthorImage(author: author) { result in
            switch result {
            case .success(let imageURL):
                downloadAndSetAuthorImage(from: imageURL)
                let logQuote = Quote(quote: quote, author: author, image: imageURL, timestamp: Date())
                withAnimation { modelContext.insert(logQuote) }
            case .failure(let error):
                handleFetchError(error: error)
            }
        }
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

    private func handleFetchError(error: Error) {
        errorMessage = error.localizedDescription
        withAnimation { authorImage = nil }
        print("Error fetching data: \(error.localizedDescription)")
    }
}

#Preview {
    QuoteView(netService: NetworkService())
}
