//
//  checkoutViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/30/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn
import Alamofire
import SwiftyJSON
import GMStepper

class checkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selectedProducts = [product]()
    var total:Double = 0
    var braintreeClient: BTAPIClient?
    var customerID:String?
    let preferences = UserDefaults.standard
    
    
    @IBOutlet weak var checkoutTableView: UITableView!
    @IBOutlet weak var totalAmount: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for product in selectedProducts {
            total = total + Double(product.price!)!
        }
        
        total = Double(round(1000*total)/1000)
        totalAmount.text = "$"+String(total)
        
        if preferences.object(forKey: "Token") == nil || preferences.object(forKey: "customerId") == nil{
                        // Token not found
                        print("Token not found")
                    } else {
                         customerID = preferences.string(forKey: "customerId")!
                    }
             
        
    }
    
    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        fetchClientToken()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedProducts.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checkoutTableView.dequeueReusableCell(withIdentifier: "checkoutCell", for: indexPath) as! checkoutTableViewCell
        
    
        cell.productName.text = selectedProducts[indexPath.row].name!
        cell.productPrice.text = "$" + selectedProducts[indexPath.row].price!
        cell.productImage.image = UIImage(named: selectedProducts[indexPath.row].imageURL!)
        cell.ProductQuantity.tag = indexPath.row
        
        cell.ProductQuantity.addTarget(self, action: #selector(self.stepperValueChanged), for: .valueChanged)
        
        return cell
     }
    
    
    @objc func stepperValueChanged(stepper: GMStepper) {
//        print(String(stepper.value) + " " + String(stepper.tag))
//        print(selectedProducts[stepper.tag].quantity)
        selectedProducts[stepper.tag].quantity = Int(stepper.value)
        calculateTotalAmount()
    }
    
    func calculateTotalAmount(){
        total = 0.00

        for product in selectedProducts {
            let quantity = product.quantity
            let price = Double(product.price!)
            
            total = total + Double(quantity) * price!
            total = Double(round(1000*total)/1000)
        }
        
        totalAmount.text = "$"+String(total)
    }
    
    //MARK: Braintree API calls
    
    func fetchClientToken() {
        
     print(customerID! + "cutsomer ID");
     let parameters: [String:String] = [
         "customerId":customerID!
     ]
     
     AF.request("http://ec2-100-27-21-19.compute-1.amazonaws.com/api/payments/getToken",
                   method: .post,
                   parameters: parameters,
                encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    self.showDropIn(clientTokenOrTokenizationKey: json["clientToken"].stringValue)
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
        
        
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
            let request =  BTDropInRequest()
            let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
            { (controller, result, error) in
                if (error != nil) {
                    print(error)
                } else if (result?.isCancelled == true) {
                    print("CANCELLED")
                } else if let result = result {
                    print("Result is")
                    
                    print(result.paymentMethod?.nonce)
                    self.postNonceToServer(paymentMethodNonce: result.paymentMethod!.nonce)
                }
                DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
                }
                
            }
            
            DispatchQueue.main.async {
                self.present(dropIn!, animated: true, completion: nil)
            }
            
        }
    
    
    func postNonceToServer(paymentMethodNonce: String) {
        
        print("nonce : " + paymentMethodNonce)
        let parameters: [String:String] = [
            "nounce":paymentMethodNonce,
            "amount":String(total)
            
        ]
        
        
        
        AF.request("http://ec2-100-27-21-19.compute-1.amazonaws.com/api/payments/checkout",
                   method: .post,
                   parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    var json = JSON(value)
                    print(json)
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
    }
        

}
