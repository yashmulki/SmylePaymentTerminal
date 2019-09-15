//
//  EnrollmentConfirmedViewController.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit

class EnrollmentConfirmedViewController: UIViewController, MessagingProtocol {

    var user: User?
    
    var message = ""
    
    func readMessage(message: String) {
        self.message = message
        performSegue(withIdentifier: "cards", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.controllers["loyaltyenroll"] = self
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegue(withIdentifier: "cards", sender: self)
        }
        
        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? RecognizedViewController {
            des.user = self.user
            des.shouldGoToPay = true
        }
    }
    

}
