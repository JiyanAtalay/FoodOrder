//
//  MenuSelectionView.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 16.09.2024.
//

import SwiftUI

struct MenuSelectionView: View {
    
    var restaurant : RestaurantModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    GroupBox {
                        HStack {
                            Text(restaurant.name)
                                .bold()
                                .font(.headline)
                            
                            Spacer()
                            AsyncImage(url: URL(string: restaurant.logo)) { phase in
                                
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(width: 70, height: 70)
                                    
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1)
                                        }
                                        .shadow(color: .gray, radius: 10, x: 0, y: 5)
                                case .failure(_):
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .foregroundStyle(.red)
                                @unknown default:
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                }
                            }
                        }
                    }.padding()
                    
                    Divider()
                        .padding()
                    
                    ForEach(restaurant.menus) { menu in
                        GroupBox {
                            VStack {
                                HStack {
                                    Text(menu.name)
                                    Spacer()
                                    Text("\(menu.price) TL")
                                }.padding(.bottom)
                                
                                HStack {
                                    Text(menu.description)
                                    Spacer()
                                    Button {
                                        //
                                    } label: {
                                        Text("Buy > ")
                                    }
                                    .buttonStyle(BorderedProminentButtonStyle())
                                    .tint(.black)

                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }.padding()
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MenuSelectionView(restaurant: RestaurantModel(isApproved: true, name: "Popeyes", rating: 4.1, tags: ["Fast Food"], latitude: 12.5, longitude: 12.5, image: "https://firebasestorage.googleapis.com:443/v0/b/foodorderapp-22fe3.appspot.com/o/media%2F0C9085F5-FEF8-4DF3-88E8-C1B89D0475B3.jpg?alt=media&token=4c927875-b2cd-4016-a0c8-5fa6816d5d42", logo: "https://firebasestorage.googleapis.com:443/v0/b/foodorderapp-22fe3.appspot.com/o/media%2F9B0F5DAE-2A07-4B92-A157-25949D754285.jpg?alt=media&token=276f1fd0-3d44-48cd-aab6-ff4eb18f890d", menus: [menuModel(name: "Big Mac", price: 120, description: "Big mac"),menuModel(name: "Chicken Sandwich", price: 150, description: "Chicken Sandwich"),menuModel(name: "French Fries", price: 100, description: "French Fries")]))
}
