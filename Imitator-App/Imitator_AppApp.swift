//
//  Imitator_AppApp.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI

@main
struct Imitator_AppApp: App {
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(Color("AccentColor"))
        }
    }
}
