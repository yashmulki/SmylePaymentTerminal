//
//  InvoiceCollectionViewCell.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit

class InvoiceCollectionViewCell: UICollectionViewCell {
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet var itemName: UILabel!
    
    func configure(price: Double, name: String) {
        itemName.text = name
        priceLabel.text = "$\(price)"
    }
    
}
