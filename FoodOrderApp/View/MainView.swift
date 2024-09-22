//
//  MainView.swift
//  FoodOrderApp
//
//  Created by Mehmet Jiyan Atalay on 16.09.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            TabView {
                RestaurantsView()
                    .tabItem {
                        Label("Restaurants", systemImage: "fork.knife")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
