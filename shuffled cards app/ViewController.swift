//
//  ViewController.swift
//  shuffled cards app
//
//  Created by user on 9/6/22.
//

import UIKit
import SVProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var deckId = ""
    var cards: [CardsResponse.Card] = []
    var currentCard: CardsResponse.Card?
    var subView: UIImageView!
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
        
        subView = UIImageView(frame: CGRect(x: width / 2, y: height * 2 , width: width, height: width * 1.3))
        
        subView.load(url: url)

        subView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.8, animations: {
            self.subView.center = CGPoint(x: width , y: height )
            }) { _ in
                self.subView.center = CGPoint(x: width , y: height )
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        subView.addGestureRecognizer(tap)
        // Swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeRight.direction = .right
        subView.addGestureRecognizer(swipeRight)
        
        self.view.addSubview(subView)
        
        isShowing = true
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        isShowing = false
    }
    
    @objc func handleSwipeGesture(sender: UIGestureRecognizer) {
        if let swipeGesture = sender as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                case .up:
                    sender.view?.removeFromSuperview()
                    isShowing = false
                case .right:
                    /* UIView.animate(withDuration: 0.8, animations: {
                        self.subView.center = CGPoint(x: self.view.frame.width * 3 , y: self.view.frame.height )
                        }) { _ in
                            self.subView.center = CGPoint(x: self.view.frame.width * 3 , y: self.view.frame.height )
                            
                    }*/
                    sender.view?.removeFromSuperview()
                    self.isShowing = false
                    print("SWIPE RIGHT")
                case .down:
                    sender.view?.removeFromSuperview()
                    isShowing = false
                case .left:
                    sender.view?.removeFromSuperview()
                    isShowing = false
            default:
                return
            }
        }
    }
    
    func getDeckId() {
        let urlString = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
        
        guard let url = URL(string: urlString) else { return }
        
        SVProgressHUD.show()
        NetworkManager.shared.get(DeckIdResponse.self, from: url) { result in
            
            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let deckIdResponse):
                self.deckId = deckIdResponse.deck_id
                print("Deck Id \(self.deckId)")
                self.getCards(deckId: deckIdResponse.deck_id)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getCards(deckId: String) {
        let urlString = "https://deckofcardsapi.com/api/deck/\(deckId)/draw/?count=52"
        
        guard let url = URL(string: urlString) else { return }
        
        SVProgressHUD.show()
        
        NetworkManager.shared.get(CardsResponse.self, from: url) { result in
                
            SVProgressHUD.dismiss()
            
            switch result {
                case .success(let cardsResponse):
                    self.cards = cardsResponse.cards
                    self.collectionView.reloadData()
                    print("Cards \(cardsResponse)")
                case .failure(let error):
                    print(error)
            }
        }
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
