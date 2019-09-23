//
//  ViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/21/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class loginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Check for the token
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: "Token") == nil {
            // Token not found
        } else {
            self.performSegue(withIdentifier: "loginToProfileSegue", sender: self)
        }
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if isEverythingFilled() == true{
            login(Email: emailTextField.text!, Password: passwordTextField.text!)
        }
    }
    
    func login(Email email:String, Password password:String){
        
        let parameters: [String:String] = [
            "email":email,
            "password":password
        ]
        
        
        AF.request("http://ec2-34-207-89-114.compute-1.amazonaws.com/user/login",
                   method: .post,
                   parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result{
                case .success(let value):
                    
                    // Get token value from response
                    let json = JSON(value)
                    let token = json["token"].stringValue
                    
                    // Store token in UserDefaults
                    let preferences = UserDefaults.standard
                    preferences.set(token, forKey: "Token")
                    
                    // Start profile segue
                    self.performSegue(withIdentifier: "loginToProfileSegue", sender: nil)
                    
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
        
    }

    
    func isEverythingFilled() -> Bool{
        
        var flag = true
        
        if emailTextField.text == "" {
            print("email is nil")
            flag = false
        }
         if passwordTextField.text == ""{
            print("password is nil")
            flag = false
        }
        
        return flag;
    }
}

