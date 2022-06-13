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
    
    var cards: [Card] = []
    var currentCard: Card!
    var currentCell: CardCollectionViewCell!
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
        getShuffle()
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
        
        cell.cardImageView.image = ImageManager.shared.loadFromUrl(url: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isShowing else { return }
        
        currentCell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        guard let image = currentCell.cardImageView.image else { return }

        let width = self.view.frame.width / 2
        let height = self.view.frame.height / 2
        
        subView = UIImageView(frame: CGRect(x: width / 2, y: height * 2 , width: width, height: width * 1.3))
        
        subView.image = image

        subView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.8, animations: {
            self.subView.center = CGPoint(x: width , y: height )
            }) { _ in
                self.subView.center = CGPoint(x: width , y: height )
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlerDismissTap))

        subView.addGestureRecognizer(tap)

        self.view.addSubview(subView)
        
        isShowing = true
        
    }
    
    @objc func handlerDismissTap(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { self.subView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height * 0.8) }) { _ in
            sender.view?.removeFromSuperview()
            self.isShowing = false
        }
    }
    
    func getShuffle() {
        let urlString = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
        
        guard let url = URL(string: urlString) else { return }
        
        SVProgressHUD.show()
        NetworkManager.shared.get(Shuffle.self, from: url) { result in
            
            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let deckIdResponse):
                self.getCards(deckId: deckIdResponse.deckId)

            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    print("OK")
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getCards(deckId: String) {
        let urlString = "https://deckofcardsapi.com/api/deck/\(deckId)/draw/?count=52"
        
        guard let url = URL(string: urlString) else { return }
        
        SVProgressHUD.show()
        
        NetworkManager.shared.get(Draw.self, from: url) { result in
                
            SVProgressHUD.dismiss()
            
            switch result {
                case .success(let cardsResponse):
                    self.cards = cardsResponse.cards
                    self.collectionView.reloadData()
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        print("OK")
                    }))
                self.present(alert, animated: true, completion: nil)
                
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

