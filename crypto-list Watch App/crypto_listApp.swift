//
//  crypto_listApp.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

@main
struct crypto_list_Watch_AppApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .applyAppTheme()
                .environmentObject(themeManager)
        }
    }
}
