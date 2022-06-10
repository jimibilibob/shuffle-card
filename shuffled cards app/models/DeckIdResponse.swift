//
//  DeckIdResponse.swift
//  shuffled cards app
//
//  Created by user on 10/6/22.
//

import Foundation

struct DeckIdResponse: Decodable {
    let success: Bool
    let deck_id: String
    let remaining: Int
    let shuffled: Bool
    
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case deck_id = "deck_id"
        case remaining = "remaining"
        case shuffled = "shuffled"
    }
}
