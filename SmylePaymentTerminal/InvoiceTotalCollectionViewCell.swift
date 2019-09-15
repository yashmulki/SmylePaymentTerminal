//
//  InvoiceTotalCollectionViewCell.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit

class InvoiceTotalCollectionViewCell: UICollectionViewCell {
    @IBOutlet var totalCost: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    
    func configure(total: Double) {
        priceLabel.text = "$\(total)"
    }
    
    
}
