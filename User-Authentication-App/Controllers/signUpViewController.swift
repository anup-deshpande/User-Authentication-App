//
//  SignUpViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/21/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class signUpViewController: UIViewController {

    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var confirmPasswordTextView: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        if isEverythingFilled() == true{
            if doPasswordsMatch() == true{
                signUp(Email: emailTextView.text!, Password: passwordTextView.text!, FirstName: firstNameTextView.text!, LastName: lastNameTextView.text!)
            }
        }
    }
    
    func signUp(Email email:String, Password password:String, FirstName firstName:String, LastName lastName:String){
        
        // MARK: SIGNUP API REQUEST 
        
        let parameters: [String:Any] = [
            "firstName":firstName,
            "lastName":lastName,
            "gender":"Male",
            "contactNo":1234567890,
            "age":26,
            "email":email,
            "password":password
        ]
        
        
    AF.request("http://ec2-34-207-89-114.compute-1.amazonaws.com/user/signUp",
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
                self.performSegue(withIdentifier: "signUpToProfileSegue", sender: nil)
                
              break
            case .failure(let error):
                print(error)
                break
            }
            
        }
        
    }
    
    func doPasswordsMatch() -> Bool{
        
        if confirmPasswordTextView.text! == passwordTextView.text! {
            return true
        }
        
        return false
    }
    
    func isEverythingFilled() -> Bool{
        var flag = true
        
        if emailTextView.text == ""{
         flag = false
        }
        
        if firstNameTextView.text == ""{
            flag = false
        }
        
        if lastNameTextView.text == ""{
            flag = false
        }
        
        if passwordTextView.text == ""{
            flag = false
        }
        
        if confirmPasswordTextView.text == ""{
            flag = false
        }
        
       
        return flag;
    }
}
