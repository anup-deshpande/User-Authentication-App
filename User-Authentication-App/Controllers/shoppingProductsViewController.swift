//
//  shoppingProductsViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/29/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import SwiftyJSON
import Braintree
import BraintreeDropIn
import Alamofire

class shoppingProductsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {


    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var braintreeClient: BTAPIClient?
    var customerID:String?
    let preferences = UserDefaults.standard
    
    var products = [product]()
    var selectedProducts = [Int : product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if preferences.object(forKey: "Token") == nil || preferences.object(forKey: "customerId") == nil{
                   // Token not found
                   print("Token not found")
               } else {
                    customerID = preferences.string(forKey: "customerId")!
               }
        
        guard let path = Bundle.main.path(forResource: "discount", ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        
        do{
        
            let data = try! Data(contentsOf: url)
            let json = try! JSON(data: data)
            
            for parsedProduct in json["results"]{
                products.append(product(json: parsedProduct.1))
            }
           
            print(products.count)
        }
        catch{
            print(error)
        }
        
        
        
         
        
    }
    
    @IBAction func payButtonTapped(_ sender: UIButton) {
        fetchClientToken()
    }
    
    @IBAction func showCartButtonTapped(_ sender: UIBarButtonItem) {
        print(selectedProducts)
    }
    
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
            "amount":"11"
            
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
        
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductsCollectionViewCell
        
        cell.productName.text = products[indexPath.row].name!
        cell.productPrice.text = products[indexPath.row].price!
        cell.productImage.image = UIImage(named: products[indexPath.row].imageURL!)
        cell.addToCartButton.tag = indexPath.row
        
        cell.addToCartButton.addTarget(self, action: #selector(self.addToCartButtonTapped), for: .touchUpInside)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(products[indexPath.row].name)
    }
    
    @objc func addToCartButtonTapped(sender: UIButton!){
        print(sender.tag)
        if(products[sender.tag].isAdded == true){
            print("True")
           sender.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
           sender.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            products[sender.tag].isAdded = false
            selectedProducts.removeValue(forKey: sender.tag)
        }else{
            print("False")
            sender.setImage(UIImage(systemName: "cart.badge.minus"), for: .normal)
            sender.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            products[sender.tag].isAdded = true
            selectedProducts[sender.tag] = products[sender.tag]
        }
            
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let Width = collectionView.bounds.width/2.0
        let Height = Width

        return CGSize(width: Width, height: Height)
    }

    
    

}
