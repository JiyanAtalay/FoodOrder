//
//  RestaurantModel.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 16.09.2024.
//

import Foundation

struct RestaurantModel : Identifiable{
    var id : UUID = UUID()
    var isApproved : Bool
    var name : String
    var rating : Double
    var tags : [String]
    var latitude : Double
    var longitude : Double
    var image : String
    var logo : String
    var menus : [menuModel]
    var distance : Double?
    
    func withDistance(_ distance: Double?) -> RestaurantModel {
        var updatedRestaurant = self
        updatedRestaurant.distance = distance
        return updatedRestaurant
    }
}


struct menuModel : Identifiable {
    var id : UUID = UUID()
    var name : String
    var price : Int
    var description : String
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "price": price,
            "description": description
        ]
    }
    
    init?(from dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let price = dictionary["price"] as? Int,
              let description = dictionary["description"] as? String else {
            return nil
        }
        
        self.name = name
        self.price = price
        self.description = description
    }
    
    init(name: String, price: Int, description: String) {
        self.name = name
        self.price = price
        self.description = description
    }
}
