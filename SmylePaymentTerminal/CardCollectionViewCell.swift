//
//  CardCollectionViewCell.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var image: UIView!
    
    @IBOutlet var imageView: UIImageView!
    
    func setDetails(card: Card) {
        if card.from == "Visa" {
            imageView.image = UIImage(named: "td-visa")
        } else if card.from == "American Express" {
             imageView.image = UIImage(named: "scotia-amex")
        } else {
             imageView.image = UIImage(named: "rbc-mastercard")
        }
    }
    
}
