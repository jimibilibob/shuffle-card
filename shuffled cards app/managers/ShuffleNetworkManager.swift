//
//  ShuffleNetworkManager.swift
//  shuffled cards app
//
//  Created by user on 13/6/22.
//

import Foundation

class ShuffleNetworkManager {
    static let shared = ShuffleNetworkManager()
    
    let baseUrlString = "https://deckofcardsapi.com"
    
    func getShuffle(completion: @escaping(Result<Shuffle, Error>) -> Void) -> Void {
        guard let url = URL(string: "\(baseUrlString)/api/deck/new/shuffle/?deck_count=1") else { return completion(.failure(ShuffleResponseError.invalidUrl)) }
        
        NetworkManager.shared.get(Shuffle.self, from: url) { result in
            switch result {
                case .success(let shuffle):
                    completion(.success(shuffle))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
