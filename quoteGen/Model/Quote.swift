//
//  Item.swift
//  quoteGen
//
//  Created by ektamannen on 03/03/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Quote {
    var quote: String
    var author: String
    var image: String?
    var timestamp: Date
    
    init(quote: String, author: String, image: String? = nil, timestamp: Date) {
        self.quote = quote
        self.author = author
        self.image = image
        self.timestamp = timestamp
    }
}
