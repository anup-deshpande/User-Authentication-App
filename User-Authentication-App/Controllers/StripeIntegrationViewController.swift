//
//  StripeIntegrationViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 10/8/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import SwiftyJSON


class StripeIntegrationViewController: UIViewController,STPAddCardViewControllerDelegate{

    //MARK: API DECLARATION
    let checkoutAPI = "http://ec2-3-88-222-179.compute-1.amazonaws.com/api/payments/Stripecheckout"
    
    let preferences = UserDefaults.standard
    var customerID:String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if preferences.object(forKey: "Token") == nil || preferences.object(forKey: "customerId") == nil
        {
            // Token not found
            print("Token not found")
        } else {
            customerID = preferences.string(forKey: "customerId")!
        }
              
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showStripeUI()
    }
    
    func showStripeUI(){
        
       
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self

        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
   func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        
        
        callCheckoutAPI(nonce: paymentMethod.stripeId)
    
        dismiss(animated: true)
   }
    
   
    
    func callCheckoutAPI(nonce stripID:String){
        
        
        let parameters: [String:Any] = [
          "amount":"1200",
          "stripeId":stripID,
          "customerId":customerID!
        ]
        
     
        
        AF.request(checkoutAPI,
                   method: .post,
                   parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    print("API called successfully \(json)")
                    self.dismiss(animated: true, completion: nil)
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
        
        
    }
    

    
    
}
