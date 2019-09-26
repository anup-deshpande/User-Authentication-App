//
//  editProfileViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/25/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class editProfileViewController: UIViewController, UITextFieldDelegate {

    let preferences = UserDefaults.standard
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var firstNameTextView: UITextField!
    @IBOutlet weak var lastNameTextView: UITextField!
    @IBOutlet weak var ageTextView: UITextField!
    @IBOutlet weak var contactTextView: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInformation()
        
        emailTextView.delegate = self
        firstNameTextView.delegate = self
        lastNameTextView.delegate = self
        ageTextView.delegate = self
        contactTextView.delegate = self
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        
        // Delete Token from User Defaults
        let prefereces = UserDefaults.standard
        
        DispatchQueue.main.async {
            prefereces.set(nil, forKey: "Token")
            prefereces.synchronize()
        }
        
        
        // Send back to login controller
        self.performSegue(withIdentifier: "editProfileToLoginSegue", sender: nil)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // Go Back to Profile Controller
        self.performSegue(withIdentifier: "editProfileToProfileSegue", sender: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        if isEverythingFilled() == true{
                
                var genderArgument: String?
                if genderSegmentedControl.selectedSegmentIndex == 0 {
                    genderArgument = "Male"
                }
                if genderSegmentedControl.selectedSegmentIndex == 1{
                    genderArgument = "Female"
                }
                
                editProfile(FirstName: firstNameTextView.text!, LastName: lastNameTextView.text!, Gender: genderArgument!, Contact: contactTextView.text!, Age: ageTextView.text!)
        }
        
    }
    
    
    
    func editProfile(FirstName firstName:String, LastName lastName:String, Gender gender: String, Contact contact:String, Age age:String){
        
        // MARK: EDIT PROFILE API REQUEST
        
        let parameters: [String:Any] = [
            "firstName":firstName,
            "lastName":lastName,
            "gender":gender,
            "contactNo":contact,
            "age":age
        ]
        
        // Get token from preferences
        let Token = preferences.string(forKey: "Token")!
        print("Token is :"+Token)
        // Prepare header
        let headers: HTTPHeaders = [
            "token": Token
            //                "token": "1"
        ]
        
        AF.request("http://ec2-18-234-241-134.compute-1.amazonaws.com/api/user/update",
                   method: .put,
                   parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
              
                    
                    // Check if status code is 200
                    if json["status"].stringValue == "200"{
                    
                        print("User Details Updated Successfully")
                        
                        // Go Back to Profile Controller
                         self.performSegue(withIdentifier: "editProfileToProfileSegue", sender: nil)
                        
                    }
                    else if json["status"].stringValue == "401"{
                       
                        print(json["message"].stringValue)
                    }
                    else if json["status"].stringValue == "400"{
                        
                        print(json["message"].stringValue)
                    }
                        
                    else{
                        print("Error Occured")
                    }
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
        
    }
    
    func getUserInformation(){
        if preferences.object(forKey: "Token") == nil {
            // Token not found
            print("Token not found")
        } else {
            
            // MARK: USER DETAIL API REQUEST
            
            // Get token from preferences
            let Token = preferences.string(forKey: "Token")!
            
            // Prepare header
            let headers: HTTPHeaders = [
                "token": Token
                //                "token": "1"
            ]
            
            // Request UserDetail Api with token in the header
            AF.request("http://ec2-18-234-241-134.compute-1.amazonaws.com/api/user/details", headers: headers)
                .responseJSON { (response) in
                    
                    switch response.result{
                    case .success(let value):
                        let json = JSON(value)
                        
                        //self.errorView.alpha = 0
                        
                        // Check if status code is 200
                        if json["status"].stringValue == "200"{
                        
                            // set Values to profile View
                            self.firstNameTextView.text = json["firstName"].stringValue
                            self.lastNameTextView.text = json["lastName"].stringValue
                            self.ageTextView.text = json["age"].stringValue
                            self.contactTextView.text = json["contactNo"].stringValue
                            self.emailTextView.text = json["email"].stringValue
                            self.emailTextView.isEnabled = false
                            
                            if json["gender"].stringValue == "Male"{
                                self.genderSegmentedControl.selectedSegmentIndex = 0
                            }else{
                                self.genderSegmentedControl.selectedSegmentIndex = 1
                            }
                            
                            //self.profileView.alpha = 1
                            
                        }
                        else if json["status"].stringValue == "400"{
                            //self.profileView.alpha = 0
                            //self.errorLabel.text = json["message"].stringValue
                            //self.errorView.alpha = 1
                            print("Error: " + json["message"].stringValue)
                            
                        }
                        
                        break
                    case .failure(let error):
                        print(error)
                      //  self.profileView.alpha = 0
                       // self.errorLabel.text = "Error in API call"
                        //self.errorView.alpha = 1
                        break
                    }
            }
            
        }
        
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
        
        
        if contactTextView.text == ""{
            flag = false
        }
        
        if ageTextView.text == ""{
            flag = false
        }
        
        return flag;
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
   


