//
//  AuthViewModel.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 16.09.2024.
//

import Foundation
import SwiftUI
import FirebaseAuth

class AuthViewModel : ObservableObject {
    @Published var isLogged: Bool = false
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        listenToAuthState()
    }
    
    func listenToAuthState() {
        handle = Auth.auth().addStateDidChangeListener{ auth, user in
            if let _ = user {
                self.isLogged = true
            } else {
                self.isLogged = false
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
