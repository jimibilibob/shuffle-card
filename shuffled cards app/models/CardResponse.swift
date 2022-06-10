//
//  CardD.swift
//  shuffled cards app
//
//  Created by user on 10/6/22.
//

import Foundation

struct CardsResponse: Decodable {
    let success: Bool
    let deck_id: String
    let cards: [Card]
    let remaining: Int
    
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case deck_id = "deck_id"
        case cards = "cards"
        case remaining = "remaining"
    }
    
    struct Card: Decodable {
        public var code: String
        public var image: String
        public var images: [String: String]
        public var value: String
        public var suit: String
    }

}
