//
//  RecognizedViewController.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit

class RecognizedViewController: UIViewController, MessagingProtocol {

    var message = ""
    var shouldGoToPay = false
    
    func readMessage(message: String) {
        
        if message.contains("Loyalty") {
            self.enrollInLoyalty()
            return
        }
        
        self.message = message
        self.readyToPay()
    }
    
    @IBOutlet var greetingLabel: UILabel!
    
    public var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let name = user?.name else {
            return
        }
        greetingLabel.text = "Hello, \(name)"
        manager.controllers["recognized"] = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if shouldGoToPay {
//            shouldGoToPay = false
//            readyToPay()
//        }
    }

    func readyToPay() {
        performSegue(withIdentifier: "cards", sender: self)
    }
    
    func configure() {
        
    }
    
    func enrollInLoyalty() {
        performSegue(withIdentifier: "rewards", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? PaymentViewController {
            var tempCards = user?.cards
        
                tempCards![0].from = "Visa"
                tempCards![1].from = "Mastercard"
                tempCards![2].from = "American Express"
            des.cards = tempCards
            des.jsonData = message
        } else if let des = segue.destination as? LoyalySignUpViewController {
            des.user = self.user
        }
        
      
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    

}
