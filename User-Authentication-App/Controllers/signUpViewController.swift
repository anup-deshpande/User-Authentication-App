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
    
    var signUpAPI = "http://ec2-3-88-222-179.compute-1.amazonaws.com/api/user/signUp"
    
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
        
        
    AF.request(signUpAPI,
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
         print("Email is blank")
         flag = false
        }
        
        if firstNameTextView.text == ""{
            print("First Name is blank")
            flag = false
        }
        
        if lastNameTextView.text == ""{
            print("Last Name is blank")
            flag = false
        }
        
        if passwordTextView.text == ""{
            print("Password is blank")
            flag = false
        }
        
        if confirmPasswordTextView.text == ""{
            print("Confirm is blank")
            flag = false
        }
        
        if contactTextView.text == ""{
            print("Contact is blank")
            flag = false
        }
        
        if ageTextView.text == ""{
            print("Age is blank")
            flag = false
        }
        
       print("Flag = "+String(flag))
        return flag;
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpToLoginSegue", sender: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
