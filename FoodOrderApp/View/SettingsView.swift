//
//  SettingsView.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 16.09.2024.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    
    @State private var showAuthView = false
    
    var body: some View {
        NavigationStack {
            Button {
                do {
                    try Auth.auth().signOut()
                    
                    showAuthView = true
                } catch {
                    print(error.localizedDescription)
                }
            } label: {
                Text("Log out")
            }

        }.navigationDestination(isPresented: $showAuthView, destination: {
            withAnimation {
                AuthView()
            }
        })
    }
}

#Preview {
    SettingsView()
}
