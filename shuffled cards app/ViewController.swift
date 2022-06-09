//
//  ViewController.swift
//  shuffled cards app
//
//  Created by user on 9/6/22.
//

import UIKit
import SVProgressHUD

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
    var currentCard: Card?
    var isShowing = false
    
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
        guard !isShowing else { return }
        // let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell ?? CardCollectionViewCell()

        currentCard = cards[indexPath.row]
        
        guard let card = currentCard else { return }
        
        guard let url = URL(string: card.image) else { return }
        // cell.cardImageView.load(url: url)
        
        let width = self.view.frame.width / 2
        let height = self.view.frame.height / 2
        
        // guard let subViewa = cell.cardImageView else { return }

        let subView = UIImageView(frame: CGRect(x: width / 2, y: height / 2, width: width, height: width * 1.3))
        
        subView.load(url: url)

        subView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.8, animations: {
            subView.center = self.view.center
            }) { _ in
                subView.center = self.view.center
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        subView.addGestureRecognizer(tap)
        
        self.view.addSubview(subView)
        
        isShowing = true
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        isShowing = false
    }
    
    func getDeckId() {
        let urlString = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        SVProgressHUD.show()
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                let data = data else { return }
            SVProgressHUD.dismiss()
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
        
        SVProgressHUD.show()
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                let data = data else { return }
            
            SVProgressHUD.dismiss()
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
