//
//  CryptoWatchApp.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

@main
struct CryptoWatchApp: App {
    
    // MARK: - Dependencies
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var currencyService = CurrencyConversionService.shared
    
    var body: some Scene {
        WindowGroup {
            CryptoListView()
                .environmentObject(settingsManager)
                .environmentObject(favoritesManager)
                .environmentObject(currencyService)
                .preferredColorScheme(.dark)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupApp() {
        // Initialize app-wide configurations
        Task {
            await currencyService.updateExchangeRates()
        }
    }
} 