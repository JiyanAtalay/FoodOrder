//
//  RestaurantsView.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 1.09.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RestaurantsView: View {
    
    @State private var showAdd = false
    
    @State private var showNavigating = false
    @State private var selectedRestaurant: RestaurantModel?
    
    @ObservedObject var viewModel = RestaurantsViewModel()
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(viewModel.filteredRestaurants) { restaurant in
                    if restaurant.isApproved {
                        VStack {
                            GroupBox {
                                HStack(spacing: 0) {
                                    AsyncImage(url: URL(string: restaurant.image)!) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width: 320, height: 180, alignment: .center)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.white, lineWidth: 1)
                                                }
                                                .shadow(color: .gray, radius: 10, x: 0, y: 5)
                                                .padding(.bottom)
                                        case .failure(_):
                                            Image(systemName: "xmark.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                        @unknown default:
                                            Image(systemName: "questionmark.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                        }
                                    }.frame(width: 320, height: 180, alignment: .center)
                                }
                                
                                HStack {
                                    Text(restaurant.name)
                                    Text("\(String(format: "%.1f", restaurant.distance ?? 0)) km")
                                    Spacer()
                                    HStack {
                                        Image(systemName: "star.fill")
                                        Text(restaurant.rating.description)
                                    }
                                }
                                Divider()
                                    .padding(.vertical, 5)
                                
                                HStack {
                                    Text(restaurant.tags.joined(separator: " - "))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .layoutPriority(-1)
                                    
                                    Spacer()
                                    
                                    Button {
                                        selectedRestaurant = restaurant
                                        showNavigating = true
                                    } label: {
                                        Text("View Menus > ")
                                    }
                                    .buttonStyle(BorderedProminentButtonStyle())
                                    .tint(.black)
                                    
                                }
                                
                            }.onTapGesture {
                                selectedRestaurant = restaurant
                                showNavigating = true
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showNavigating, destination: {
                if let restaurant = selectedRestaurant {
                    MenuSelectionView(restaurant: restaurant)
                        .onDisappear {
                            self.showNavigating = false
                            self.selectedRestaurant = nil
                        }
                }
            })
            .navigationTitle("Restaurants")
            .toolbarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Text("Add")
                    }

                }
            })
            .fullScreenCover(isPresented: $showAdd, onDismiss: {
                showAdd = false
            }, content: {
                RestaurantsAddView()
            })
        }
        .onAppear {
            viewModel.getRestaurants()
            locationManager.startUpdatingLocation()
        }
    }
}

#Preview {
    RestaurantsView()
}
