//
//  product.swift
//  User-Authentication-App
//
//  Created by Anup Deshpande on 9/29/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import Foundation
import SwiftyJSON

class product{
    var name:String?
    var imageURL:String?
    var price:String?
    var discount:String?
    var isAdded:Bool = false
    
    init(json: JSON) {
           self.name = json["name"].stringValue
           self.imageURL = json["photo"].stringValue
           self.discount = json["discount"].stringValue
           self.price = json["price"].stringValue
   }
}
