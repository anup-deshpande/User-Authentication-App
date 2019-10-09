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

class loginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    
    var loginAPI = "http://ec2-3-88-222-179.compute-1.amazonaws.com/api/user/login"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorView.alpha = 0
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        // Check for the token
        let preferences = UserDefaults.standard

        
        if preferences.string(forKey: "Token") == nil {
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
        
        // MARK: LOGIN API REQUEST 

        let parameters: [String:String] = [
            "email":email,
            "password":password
        ]
        
        
        AF.request(loginAPI,
                   method: .post,
                   parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    self.errorView.alpha = 0
                    // Get token value from response
                    let json = JSON(value)
                    if json["status"].stringValue == "200"{
                    let token = json["token"].stringValue
                    let customerId = json["customerId"].stringValue
                    print("Customer ID is  : \(customerId)")
                        
                    // Store token in UserDefaults
                    let preferences = UserDefaults.standard
                    preferences.set(token, forKey: "Token")
                    preferences.set(customerId, forKey: "customerId")
                    
                    // Start profile segue
                    self.performSegue(withIdentifier: "loginToProfileSegue", sender: nil)
                    }
                    else if json["status"].stringValue == "400"{
                        self.errorLabel.text = json["message"].stringValue
                       
                        self.errorView.alpha = 1
                    }
                    
                    break
                    
                case .failure(let error):
                    print(error)
                    self.errorLabel.text = "Failed to call login API"
                    self.errorView.alpha = 1
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

