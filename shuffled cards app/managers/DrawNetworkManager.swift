//
//  DrawNetworkManager.swift
//  shuffled cards app
//
//  Created by user on 13/6/22.
//

import Foundation

class DrawNetworkManager {
    static let shared = DrawNetworkManager()
    
    let baseUrlString = "https://deckofcardsapi.com"
    
    func getDraw(deckId: String, completion: @escaping (Result<Draw, Error>) -> Void) -> Void {
        guard let url = URL(string: "\(baseUrlString)/api/deck/\(deckId)/draw/?count=52") else { return completion(.failure(DrawResponseError.invalidUrl)) }

        NetworkManager.shared.get(Draw.self, from: url) { result in
            switch result {
                case .success(let draw):
                completion(.success(draw))
                case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
