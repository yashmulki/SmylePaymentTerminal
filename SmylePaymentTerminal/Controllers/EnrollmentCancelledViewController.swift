//
//  EnrollmentCancelledViewController.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit

class EnrollmentCancelledViewController: UIViewController, MessagingProtocol {
  
    var message = ""
    var user: User?
    
    func readMessage(message: String) {
        self.message = message
        performSegue(withIdentifier: "cards", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.controllers["loyaltycancel"] = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegue(withIdentifier: "cards", sender: self)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? RecognizedViewController {
            des.user = self.user
             des.shouldGoToPay = true
        }
    }
    

}
