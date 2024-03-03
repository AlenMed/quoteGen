//
//  Item.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import Foundation
import SwiftData

@Model
final class Quote {
    var quote: String
    var author: String
    var timestamp: Date
    
    init(quote: String, author: String, timestamp: Date) {
        self.quote = quote
        self.author = author
        self.timestamp = timestamp
    }
}
