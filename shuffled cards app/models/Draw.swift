import Foundation

// MARK: - Draw
struct Draw: Codable {
    let success: Bool
    let deckID: String
    let cards: [Card]
    let remaining: Int

    enum CodingKeys: String, CodingKey {
        case success
        case deckID = "deck_id"
        case cards, remaining
    }
}

// MARK: - Card
struct Card: Codable {
    let code: String
    let image: String
    let images: Images
    let value: String
    let suit: String
}

// MARK: - Images
struct Images: Codable {
    let svg: String
    let png: String
}

enum DrawResponseError: Error {
    case noData
    case invalidUrl
}
