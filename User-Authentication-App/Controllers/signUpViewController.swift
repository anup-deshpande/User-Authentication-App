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

class signUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var confirmPasswordTextView: UITextField!
    @IBOutlet weak var ageTextView: UITextField!
    @IBOutlet weak var contactTextView: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextView.delegate = self
        firstNameTextView.delegate = self
        lastNameTextView.delegate = self
        passwordTextView.delegate = self
        confirmPasswordTextView.delegate = self
        ageTextView.delegate = self
        contactTextView.delegate = self
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        if isEverythingFilled() == true{
            if doPasswordsMatch() == true{
                
                var genderArgument: String?
                if genderSegmentedControl.selectedSegmentIndex == 0 {
                    genderArgument = "Male"
                }
                if genderSegmentedControl.selectedSegmentIndex == 1{
                    genderArgument = "Female"
                }
                
                signUp(Email: emailTextView.text!, Password: passwordTextView.text!, FirstName: firstNameTextView.text!, LastName: lastNameTextView.text!, Gender: genderArgument!, Contact: contactTextView.text!, Age: ageTextView.text!)
            }
        }
    }
    
    func signUp(Email email:String, Password password:String, FirstName firstName:String, LastName lastName:String, Gender gender: String, Contact contact:String, Age age:String){
        
        // MARK: SIGNUP API REQUEST 
        
        let parameters: [String:Any] = [
            "firstName":firstName,
            "lastName":lastName,
            "gender":gender,
            "contactNo":contact,
            "age":age,
            "email":email,
            "password":password
        ]
        
        
    AF.request("http://ec2-18-234-241-134.compute-1.amazonaws.com/api/user/signUp",
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
        
        if contactTextView.text == ""{
            flag = false
        }
        
        if ageTextView.text == ""{
            flag = false
        }
        
       print("Please input all fields")
        return flag;
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpToLoginSegue", sender: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
