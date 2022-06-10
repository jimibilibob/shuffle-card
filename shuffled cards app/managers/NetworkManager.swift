//
//  NetworkManager.swift
//  shuffled cards app
//
//  Created by user on 10/6/22.
//

import Foundation

enum CardResponseError: Error {
    case noData
}

class NetworkManager {
    static let shared = NetworkManager(session: URLSession.shared)
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    @discardableResult
    func get<T: Decodable>(_ type: T.Type, from url: URL, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Error !! \(error)")
                DispatchQueue.main.sync {
                    completion(.failure(error))
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            if let data = data, let items = try? jsonDecoder.decode(type, from: data) {
                DispatchQueue.main.sync {
                    completion(.success(items))
                }
            } else {
                DispatchQueue.main.sync {
                    completion(.failure(CardResponseError.noData))
                }
            }
        }
        task.resume()
        
        return task
    }
}
