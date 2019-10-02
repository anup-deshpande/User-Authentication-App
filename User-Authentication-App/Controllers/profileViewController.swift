//
//  profileViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/22/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class profileViewController: UIViewController {

    let preferences = UserDefaults.standard
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var userSinceLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.alpha = 0
        errorView.alpha = 0
        getUserInformation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check for the token
        if preferences.object(forKey: "Token") == nil {
            // Token not found
            print("Token not found")
        } else {
            print("Token found" + preferences.string(forKey: "Token")!)
            
        }
    }
    
   
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        logOut()
    }
    
    func logOut(){
        // Delete Token from User Defaults
        let prefereces = UserDefaults.standard
        
        DispatchQueue.main.async {
            prefereces.set(nil, forKey: "Token")
            prefereces.synchronize()
        }
        
        
        // Send back to login controller
        self.performSegue(withIdentifier: "profileToLoginSegue", sender: nil)
    }
    
    @IBAction func deleteProfileButtonTapped(_ sender: UIButton) {
        deleteUserProfile()
    }
    
    @IBAction func editProfileButtonTapped(_ sender: UIButton) {
        
        // Go to edit profile controller
        self.performSegue(withIdentifier: "profileToEditProfileSegue", sender: nil)
    }
    
    @IBAction func shopButtonTapped(_ sender: UIButton) {
        
        // Go to shopping product controller
        self.performSegue(withIdentifier: "profileToShoppingSegue", sender: nil)
        
        
    }
    
    func deleteUserProfile(){
        
        if preferences.object(forKey: "Token") == nil {
            // Token not found
            print("Token not found")
        } else {
            
            // MARK: USER DELETE API REQUEST
            
            // Get token from preferences
            let Token = preferences.string(forKey: "Token")!
            print("Token is :"+Token)
            // Prepare header
            let headers: HTTPHeaders = [
                "token": Token
//                                "token": "1"
            ]
            
            // Request UserDetail Api with token in the header
            AF.request("http://ec2-100-27-21-19.compute-1.amazonaws.com/api/user/delete",
                       method: .delete,
                       headers: headers)
                .responseJSON { (response) in
                    
                    switch response.result{
                    case .success(let value):
                        let json = JSON(value)
                        
                        self.errorView.alpha = 0
                        
                        // Check if status code is 200
                        if json["status"].stringValue == "200"{
                          
                            print("Delete user successful")
                            self.logOut()
                            
                        }
                        else if json["status"].stringValue == "400"{
                            self.profileView.alpha = 0
                            self.errorLabel.text = json["message"].stringValue
                            self.errorView.alpha = 1
                            print("Error: " + json["message"].stringValue)
                            
                        }
                        
                        break
                    case .failure(let error):
                        print(error)
                       // self.profileView.alpha = 0
                        self.errorLabel.text = "Error in API call"
                        self.errorView.alpha = 1
                        break
                    }
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
            print("Token is :"+Token)
            // Prepare header
            let headers: HTTPHeaders = [
                "token": Token
//                "token": "1"
            ]

            // Request UserDetail Api with token in the header
            AF.request("http://ec2-100-27-21-19.compute-1.amazonaws.com/api/user/details", headers: headers)
                .responseJSON { (response) in
                    
                    switch response.result{
                    case .success(let value):
                        let json = JSON(value)
                        
                        self.errorView.alpha = 0
                        
                        // Check if status code is 200
                        if json["status"].stringValue == "200"{
                            let createdAt:String = json["createdAt"].stringValue
                            
                            // set Values to profile View
                            self.nameLabel.text = json["firstName"].stringValue + " " +  json["lastName"].stringValue
                            self.ageLabel.text = json["age"].stringValue
                            self.contactLabel.text = json["contactNo"].stringValue
                            self.genderLabel.text = json["gender"].stringValue
                            self.emailLabel.text = json["email"].stringValue
                            self.userSinceLabel.text = String(createdAt.split(separator: "T", maxSplits: 2, omittingEmptySubsequences: true).first!)
                            
                            self.profileView.alpha = 1
                            
                        }
                        else{
                            self.profileView.alpha = 0
                            self.errorLabel.text = json["message"].stringValue
                            self.errorView.alpha = 1
                             print("Error: " + json["message"].stringValue)
                        }
                        
                        break
                    case .failure(let error):
                        print(error)
                        self.profileView.alpha = 0
                        self.errorLabel.text = "Error in API call. Check URL"
                        self.errorView.alpha = 1
                        break
                    }
            }

        }
    }
}

