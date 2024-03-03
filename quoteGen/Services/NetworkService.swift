//
//  NetworkService.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import Foundation

@Observable
class NetworkService {
    let zenApiUrl = "https://zenquotes.io/api/quotes/"
    let wikiApiUrl = "https://en.wikipedia.org/w/api.php"
    
    func getQuote(completion: @escaping (Result<(Quote), Error>) -> Void) {
        guard let apiUrl = URL(string: zenApiUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: apiUrl) { (data, response, error) in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                if let quotesArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]], let quoteData = quotesArray.first {
                    if let quote = quoteData["q"] as? String, let author = quoteData["a"] as? String {
                        let quoteObject = Quote(quote: quote, author: author, timestamp: Date())
                        completion(.success((quoteObject)))
                    } else {
                        completion(.failure(NSError(domain: "Invalid quote data", code: 0, userInfo: nil)))
                    }
                } else {
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func getAuthorImage(author: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: String] = [
            "action": "query",
            "format": "json",
            "prop": "pageimages",
            "titles": author,
            "redirects": "1",
            "pithumbsize": "500"
        ]
        
        guard var urlComponents = URLComponents(string: wikiApiUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "Unknown error", code: 0, userInfo: nil)))
                }
                return
            }
            
            // Print JSON data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                guard let query = json["query"] as? [String: Any],
                      let pages = query["pages"] as? [String: Any],
                      let page = pages.values.first as? [String: Any],
                      let thumbnail = page["thumbnail"] as? [String: Any],
                      let imageUrlString = thumbnail["source"] as? String else {
                    completion(.failure(NSError(domain: "Invalid JSON Response", code: 0, userInfo: nil)))
                    return
                }
                
                completion(.success(imageUrlString))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

}
