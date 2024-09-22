//
//  RestaurantsAddView.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 13.09.2024.
//

import SwiftUI
import Firebase
import FirebaseStorage
import PhotosUI

struct RestaurantsAddView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var latitude : String = ""
    @State private var longitude : String = ""
    @State private var tags : [String] = [""]
    @State private var menus : [menuModel] = [menuModel(name: "", price: 0, description: "")]
    
    @State var selectedItemImage : [PhotosPickerItem] = []
    @State var dataImage : Data?
    @State var selectedItemLogo : [PhotosPickerItem] = []
    @State var dataLogo : Data?
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Divider()
                        .padding()
                    
                    Text("Name")
                    
                    GroupBox {
                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider()
                        .padding()
                    
                    Text("Location")
                    
                    GroupBox {
                        TextField("Latitude", text: $latitude)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        TextField("Longitude", text: $longitude)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    Divider()
                        .padding()
                    
                    Text("Tags")
                    
                   
                    ForEach(0..<tags.count, id: \.self) { index in
                        GroupBox {
                            VStack {
                                HStack {
                                    TextField("Enter tag", text: $tags[index])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button(action: {
                                        withAnimation {
                                            if index < tags.count {
                                                tags.remove(at: index)
                                            }
                                        }
                                    }, label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                        
                                    })
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            tags.append("")
                        }
                    }, label: {
                        Text("Add")
                    }).padding(.vertical)
                    
                    Divider()
                        .padding()
                    
                    Text("Menus")
                    
                    
                    ForEach(0..<menus.count, id: \.self) { index in
                        GroupBox {
                            VStack {
                                HStack {
                                    TextField("Enter menu name", text: $menus[index].name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Picker("", selection: $menus[index].price) {
                                        ForEach(Array(stride(from: 0, through: 10000, by: 10)), id: \.self) { i in
                                            Text("\(i) TL").tag(i)
                                        }
                                    }
                                }
                                
                                HStack {
                                    TextField("Enter menu description", text: $menus[index].description)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button(action: {
                                        withAnimation {
                                            if index < menus.count {
                                                menus.remove(at: index)
                                            }
                                        }
                                    }, label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                            .padding(.horizontal,5)
                                    })
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            menus.append(menuModel(name: "", price: 0, description: ""))
                        }
                    }, label: {
                        Text("Add")
                    }).padding(.vertical)
                    
                    Divider()
                        .padding()
                    
                    if let data = dataLogo {
                        if let selectedImage = UIImage(data: data) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .frame(width: 90, height: 75, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                        
                                }
                        }
                    }
                    
                    PhotosPicker(selection: $selectedItemLogo, maxSelectionCount: 1, matching: .images) {
                        Text("Select Logo")
                            .padding()
                    }.onChange(of: selectedItemLogo) { oldValue ,newValue in
                        
                        guard let item = selectedItemLogo.first else {
                            return
                        }
                        
                        item.loadTransferable(type: Data.self) { result in
                            switch result{
                            case .success(let data):
                                self.dataLogo = data
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    
                    Divider()
                        .padding()
                    
                    if let data = dataImage {
                        if let selectedImage = UIImage(data: data) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .frame(width: 300, height: 250, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                }
                                .shadow(color: .gray, radius: 10, x: 0, y: 5)
                        }
                    }
                    
                    PhotosPicker(selection: $selectedItemImage, maxSelectionCount: 1, matching: .images) {
                        Text("Select Image")
                            .padding()
                    }.onChange(of: selectedItemImage) { oldValue ,newValue in
                        
                        guard let item = selectedItemImage.first else {
                            return
                        }
                        
                        item.loadTransferable(type: Data.self) { result in
                            switch result{
                            case .success(let data):
                                self.dataImage = data
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    
                    
                    Divider()
                        .padding()
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Leave")
                        }).buttonStyle(BorderedProminentButtonStyle())
                            .padding(.horizontal)
                        
                        Button {
                            
                            let restaurantRef = db.collection("Restaurants")
                            let menusDictionary = menus.map{ $0.toDictionary() }
                            
                            let storage = Storage.storage()
                            let storageRef = storage.reference()
                            
                            let mediaFolder = storageRef.child("media")
                            
                            if let dataImage {
                                if let dataLogo {
                                    let imageRefImage = mediaFolder.child("\(UUID().uuidString).jpg")
                                    let imageRefLogo = mediaFolder.child("\(UUID().uuidString).jpg")
                                    
                                    imageRefImage.putData(dataImage, metadata: nil) { metadataImage, errorImage in
                                        if let errorImage {
                                            print("Resim yüklenirken hata oluştu1: \(errorImage.localizedDescription)")
                                        } else {
                                            imageRefLogo.putData(dataLogo, metadata: nil) { metadataLogo, errorLogo in
                                                if let errorLogo {
                                                    print("Logo yüklenirken hata oluştu1: \(errorLogo.localizedDescription)")
                                                } else {
                                                    imageRefImage.downloadURL { urlImage, errorImage in
                                                        if let errorImage {
                                                            print("Resim yüklenirken hata oluştu2: \(errorImage.localizedDescription)")
                                                        } else {
                                                            imageRefLogo.downloadURL { urlLogo, errorLogo in
                                                                if let errorLogo {
                                                                    print("Logo yüklenirken hata oluştu2: \(errorLogo.localizedDescription)")
                                                                } else {
                                                                    let imageUrlImage = urlImage?.absoluteString
                                                                    let imageUrlLogo = urlLogo?.absoluteString
                                                                    
                                                                    restaurantRef.addDocument(data: [
                                                                        "isApproved" : false,
                                                                        "name" : name,
                                                                        "rating" : 0.0,
                                                                        "latitude" : latitude.replacingOccurrences(of: ",", with: "."),
                                                                        "longitude" : longitude.replacingOccurrences(of: ",", with: "."),
                                                                        "tags" : tags,
                                                                        "menus" : menusDictionary,
                                                                        "image" : imageUrlImage!,
                                                                        "logo" : imageUrlLogo!
                                                                    ]) { error in
                                                                        if let error = error {
                                                                            print("Veri eklenirken hata oluştu: \(error.localizedDescription)")
                                                                        } else {
                                                                            print("Restoran ve menü bilgileri başarıyla eklendi!")
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
                            
                            dismiss()
                        } label: {
                            Text("Save")
                        }.buttonStyle(BorderedProminentButtonStyle())
                            .padding(.horizontal)
                    }

                }
            }.navigationTitle("Add Restaurant")
                .toolbarTitleDisplayMode(.inlineLarge)
        }.autocorrectionDisabled(true)
    }
}

#Preview {
    RestaurantsAddView()
}
