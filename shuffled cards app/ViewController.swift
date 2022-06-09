//
//  ViewController.swift
//  shuffled cards app
//
//  Created by user on 9/6/22.
//

import UIKit

struct Card {
    public var code: String
    public var image: String
    public var images: [String: String]
    public var value: String
    public var suit: String
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var deckId = ""
    var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let uiNib = UINib(nibName: "CardCollectionViewCell", bundle: nil)
        collectionView.register(uiNib, forCellWithReuseIdentifier: "CardCollectionViewCell")
    }

    @IBAction func shuffleCards(_ sender: Any) {
        getDeckId()
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell ?? CardCollectionViewCell()
        let card = cards[indexPath.row]

        guard let url = URL(string: card.image) else { return cell }
        cell.cardImageView.load(url: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // currentCard = characters[indexPath.row]
        // TODO: Show card image performSegue(withIdentifier: "goToDetailViewController", sender: nil)
    }
    
    func getDeckId() {
        let urlString = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                let data = data else { return }
            
            do{
                if let deckIdJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    guard let id = deckIdJson["deck_id"] as? String else { return }
                    self.deckId = id
                }
                
                DispatchQueue.main.sync {
                    print("Deck Id \(self.deckId)")
                    self.getCards(deckId: self.deckId)
                    print("Cards \(self.cards)")
                    //self.collectionView.reloadData()
                }
                
            } catch {
                print("Error", error)
            }
        }
        
        task.resume()
    }
    
    func getCards(deckId: String) {
        let urlString = "https://deckofcardsapi.com/api/deck/\(deckId)/draw/?count=52"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                let data = data else { return }
            do{
                if let requestCardJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    self.cards.removeAll()
                    
                    guard let cardsJson = requestCardJson["cards"] as? [[String: Any]] else { return }
                    print("Card Data ----> \(cardsJson)")
                    for cardDic in cardsJson {
                        
                        guard let code = cardDic["code"] as? String,
                              let image = cardDic["image"] as? String,
                              let images = cardDic["images"] as? [String: String],
                              let value = cardDic["value"] as? String,
                              let suit = cardDic["suit"] as? String else { continue }
                        
                        let card = Card(code: code, image: image, images: images, value: value, suit: suit)
                        
                        self.cards.append(card)
                    }
                }
                
                DispatchQueue.main.sync {
                    
                    self.collectionView.reloadData()
                }
                
            } catch {
                print("Error", error)
            }
        }
        
        task.resume()
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {
    // STIMATED_SIZE in collection view = NONE iOS
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("CollectionView CGSize")
        let width = collectionView.frame.width / 4
        return CGSize(width: width, height: width)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
}
