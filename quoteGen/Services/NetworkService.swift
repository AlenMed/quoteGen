//
//  NetworkService.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import Foundation

@Observable
class NetworkService {
    let apiUrl = "https://zenquotes.io/api/quotes/"
    
    func getApiData(completion: @escaping (Result<(quote: String, author: String), Error>) -> Void) {
        guard let apiUrl = URL(string: apiUrl) else {
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
                        completion(.success((quote, author)))
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
}
