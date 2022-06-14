//
//  DeckIdResponse.swift
//  shuffled cards app
//
//  Created by user on 10/6/22.
//

import Foundation

struct Shuffle: Decodable {
    let success: Bool
    let deckId: String
    let remaining: Int
    let shuffled: Bool
    
    enum CodingKeys: String, CodingKey {
        case success, remaining, shuffled
        case deckId = "deck_id"
    }
}

enum ShuffleResponseError: Error {
    case noData
    case invalidUrl
}
