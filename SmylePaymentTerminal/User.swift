//
//  User.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import Foundation

struct User: Codable {
    let name: String
    let cards: [Card]
    let purchaseHistory: [Purchase]
}

struct Card: Codable {
    let number: String
    let cvv: Int
    var from: String
}

struct Purchase: Codable {
    
    let card: Card
    let amount: Int
    let date: String
    let location: String
    
}

struct Item: Codable {
    let name: String
    let cost: Double
}
