//
//  profileViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/22/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit

class profileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check for the token
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: "Token") == nil {
            // Token not found
            print("Token not found")
        } else {
            print("Token found" + preferences.string(forKey: "Token")!)
        }
    }
    
    @IBAction func showProfileTapped(_ sender: UIButton) {
        print("Show Profile Button tapped")
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        
        // Delete Token from User Defaults
        let prefereces = UserDefaults.standard
        prefereces.removeObject(forKey: "Token")
        prefereces.synchronize()
        
        // Send back to login controller
        self.performSegue(withIdentifier: "profileToLoginSegue", sender: self)
        self.dismiss(animated: true, completion: nil)
        
    }
}
