//
//  shoppingProductsViewController.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/29/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class shoppingProductsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {


    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        
        
        
         
        
    }
    
    
    
    @IBAction func showCartButtonTapped(_ sender: UIBarButtonItem) {
        print(selectedProducts)
        self.performSegue(withIdentifier: "shopToCheckoutSegue", sender: nil)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductsCollectionViewCell
        
        
        let discount = Double(products[indexPath.row].discount!)
        let originalPrice = Double(products[indexPath.row].price!)
        
        var discountedPrice = originalPrice! - (originalPrice! * (discount!/100))
        discountedPrice = (discountedPrice * 100).rounded()/100
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "$"+String(originalPrice!))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        cell.productName.text = products[indexPath.row].name!
        //cell.productOriginalPrice.text = "$" + products[indexPath.row].price!
        cell.productImage.image = UIImage(named: products[indexPath.row].imageURL!)
        cell.addToCartButton.tag = indexPath.row
        cell.productOriginalPrice.attributedText = attributeString
        cell.productDiscountedPrice.text = "$"+String(discountedPrice)
        
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
           sender.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
           sender.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            products[sender.tag].isAdded = false
            selectedProducts.removeValue(forKey: sender.tag)
        }else{
            sender.setImage(UIImage(systemName: "cart.badge.minus"), for: .normal)
            sender.tintColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            products[sender.tag].isAdded = true
            selectedProducts[sender.tag] = products[sender.tag]
        }
            
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let Width = collectionView.bounds.width/2.0
        let Height = Width

        return CGSize(width: Width, height: Height)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shopToCheckoutSegue"{
            let destination = segue.destination as! checkoutViewController

            for key in selectedProducts.keys{
                destination.selectedProducts.append(self.selectedProducts[key]!)
            }
        }
    }
    

}
