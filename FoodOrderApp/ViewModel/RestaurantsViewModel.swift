//
//  RestaurantsViewModel.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 16.09.2024.
//

import Foundation
import Firebase

class RestaurantsViewModel : ObservableObject {
    private var db = Firestore.firestore()
    private var locationManager = LocationManager()
    
    @Published var restaurants = [RestaurantModel]()
    @Published var filteredRestaurants = [RestaurantModel]()
    
    var userLatitude: Double? {
        locationManager.location?.coordinate.latitude
    }
        
    var userLongitude: Double? {
        locationManager.location?.coordinate.longitude
    }
    
    init() {
        locationManager.startUpdatingLocation()
    }
    
    func getRestaurants() {
        db.collection("Restaurants").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription as Any)
            } else {
                self.restaurants.removeAll(keepingCapacity: false)
                
                for document in snapshot!.documents {
                    _ = document.documentID
                    if let isApproved = document.get("isApproved") as? Bool {
                        if let name = document.get("name") as? String {
                            if let rating = document.get("rating") as? Double {
                                if let tags = document.get("tags") as? [String] {
                                    if let latitude  = document.get("latitude") as? String {
                                        if let longitude = document.get("longitude") as? String {
                                            if let image = document.get("image") as? String {
                                                if let logo = document.get("logo") as? String {
                                                    if let menusDict = document.get("menus") as? [[String : Any]] {
                                                        
                                                        var menus = [menuModel]()
                                                        
                                                        for menuData in menusDict {
                                                            if let menu = menuModel(from: menuData) {
                                                                menus.append(menu)
                                                            }
                                                        }
                                                        
                                                        let restaurantLatitude = Double(latitude) ?? 0.0
                                                        let restaurantLongitude = Double(longitude) ?? 0.0
                                                        
                                                        let currentRestaurant = RestaurantModel(isApproved: isApproved, name: name, rating: rating, tags: tags, latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0, image: image, logo: logo, menus: menus)
                                                        
                                                        if let userLat = self.userLatitude, let userLong = self.userLongitude {
                                                            let distance = self.locationManager.haversineDistance(lat1: userLat, lon1: userLong, lat2: restaurantLatitude, lon2: restaurantLongitude)
                                                            
                                                            print("userLat : \(userLat), userLong : \(userLong), restaurantLatitude : \(restaurantLatitude), restaurantLongitude : \(restaurantLongitude), distance : \(distance)")
                                                            
                                                            // Eğer mesafe 5 km'den küçükse, listeye ekle
                                                            if distance <= 5.0 {
                                                                self.filteredRestaurants.append(currentRestaurant.withDistance(distance))
                                                            }
                                                        }
                                                        
                                                        self.restaurants.append(currentRestaurant)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
