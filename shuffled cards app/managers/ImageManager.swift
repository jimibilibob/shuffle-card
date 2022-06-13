//
//  ImageManager.swift
//  shuffled cards app
//
//  Created by user on 13/6/22.
//

import Foundation
import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    func loadFromUrl(url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
