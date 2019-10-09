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
import KRProgressHUD
import Stripe

class checkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,STPAddCardViewControllerDelegate {
  
    //MARK: API DECLARATION
    let checkoutAPI = "http://ec2-3-88-222-179.compute-1.amazonaws.com/api/payments/Stripecheckout"
    
    
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
        cell.ProductQuantity.value = Double(selectedProducts[indexPath.row].quantity)
        
        if selectedProducts[indexPath.row].imageURL! == "null"{
            cell.productImage.image = UIImage(named: "no-image")
        }else{
            cell.productImage.image = UIImage(named: selectedProducts[indexPath.row].imageURL!)
        }
       
        cell.ProductQuantity.tag = indexPath.row
        
        cell.ProductQuantity.addTarget(self, action: #selector(self.stepperValueChanged), for: .valueChanged)
        
        return cell
     }
    
    
    @objc func stepperValueChanged(stepper: GMStepper) {
        selectedProducts[stepper.tag].quantity = Int(stepper.value)
        
        if Int(stepper.value) == 0 {
            
            let alert = UIAlertController(title: "Please confirm", message: "Are you sure you want to delete " + selectedProducts[stepper.tag].name!
                , preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            (alert) -> Void in
                self.selectedProducts.remove(at: stepper.tag)
                self.checkoutTableView.reloadData()
            })
            
            let deleteAction = UIAlertAction(title: "Cancel", style: .destructive,handler: {
            (alert) -> Void in
                stepper.value = stepper.value + 1
            })
            
            alert.addAction(confirmAction)
            alert.addAction(deleteAction)
            
            self.present(alert, animated: true, completion: nil)
            
           
        }

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
                    KRProgressHUD.showSuccess(withMessage: "Your order is placed")
                    
                    self.selectedProducts.removeAll()
                    self.checkoutTableView.reloadData()
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "checkoutToShopSegue", sender: nil)
                    }
                    
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
    }
        

    func getEphemeralKey() -> String {
        
        
        let parameters: [String:String] = [
                "customerId":"\(customerID!)"
        ]
        
        AF.request("http://ec2-3-88-222-179.compute-1.amazonaws.com/api/payments/ephemeralKeys",
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
        
        return "abcd"
        
        
     }
     
     
     
    //MARK: Stripe API calls
    
    @IBAction func checkoutWithStripebuttonTapped(_ sender: UIButton) {
        print("Checkout pressed")
        
        var eKey = getEphemeralKey()
        print(eKey)
        
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
            "amount":self.total * 100,
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
