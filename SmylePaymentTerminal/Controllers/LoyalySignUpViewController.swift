//
//  LoyalySignUpViewController.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-13.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit

class LoyalySignUpViewController: UIViewController, MessagingProtocol {
    
    var user: User?
    
    func readMessage(message: String) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func yes(_ sender: Any) {
        performSegue(withIdentifier: "enrolled", sender: self)
    }
    
    @IBAction func no(_ sender: Any) {
         performSegue(withIdentifier: "cancelled", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? EnrollmentConfirmedViewController {
            
            des.user = self.user
            
        } else if let des = segue.destination as? EnrollmentCancelledViewController {
            
             des.user = self.user
            
        }
    }
 

}
