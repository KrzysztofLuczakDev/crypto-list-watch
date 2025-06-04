//
//  SettingsManager.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Settings Manager Protocol

protocol SettingsManagerProtocol: ObservableObject {
    var currencyPreference: CurrencyPreference { get set }
    var dataRefreshInterval: DataRefreshInterval { get set }
    var watchlistSorting: WatchlistSortingPreference { get set }
    
    func resetToDefaults()
    func getCurrentRefreshInterval() -> TimeInterval?
    func shouldAutoRefresh() -> Bool
}

// MARK: - Settings Manager

final class SettingsManager: SettingsManagerProtocol {
    static let shared = SettingsManager()
    
    // Use App Groups for sharing data between app and widget
    private let userDefaults = UserDefaults(suiteName: "group.krzysztof-luczak.crypto-watch") ?? UserDefaults.standard
    
    // MARK: - Settings Keys
    private struct Keys {
        static let currency = "currency_preference"
        static let dataRefreshInterval = "data_refresh_interval"
        static let watchlistSorting = "watchlist_sorting"
    }
    
    // MARK: - Published Properties
    @Published var currencyPreference: CurrencyPreference {
        didSet { 
            saveCurrencyPreference()
            postSettingsChangeNotification()
        }
    }
    
    @Published var dataRefreshInterval: DataRefreshInterval {
        didSet { 
            saveDataRefreshInterval()
            postSettingsChangeNotification()
        }
    }
    
    @Published var watchlistSorting: WatchlistSortingPreference {
        didSet { 
            saveWatchlistSorting()
            postSettingsChangeNotification()
        }
    }
    
    private init() {
        // Load saved settings or use defaults
        self.currencyPreference = CurrencyPreference(rawValue: userDefaults.string(forKey: Keys.currency) ?? "") ?? .usd
        self.dataRefreshInterval = DataRefreshInterval(rawValue: userDefaults.string(forKey: Keys.dataRefreshInterval) ?? "") ?? .live
        self.watchlistSorting = WatchlistSortingPreference(rawValue: userDefaults.string(forKey: Keys.watchlistSorting) ?? "") ?? .marketCap
    }
    
    // MARK: - Save Methods
    private func saveCurrencyPreference() {
        userDefaults.set(currencyPreference.rawValue, forKey: Keys.currency)
    }
    
    private func saveDataRefreshInterval() {
        userDefaults.set(dataRefreshInterval.rawValue, forKey: Keys.dataRefreshInterval)
    }
    
    private func saveWatchlistSorting() {
        userDefaults.set(watchlistSorting.rawValue, forKey: Keys.watchlistSorting)
    }
    
    private func postSettingsChangeNotification() {
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    // MARK: - Reset Methods
    func resetToDefaults() {
        currencyPreference = .usd
        dataRefreshInterval = .live
        watchlistSorting = .marketCap
    }
    
    // MARK: - Utility Methods
    func getCurrentRefreshInterval() -> TimeInterval? {
        return dataRefreshInterval.seconds
    }
    
    func shouldAutoRefresh() -> Bool {
        return true // Always auto-refresh since all options are automatic
    }
}

// MARK: - Mock Settings Manager for Previews

final class MockSettingsManager: SettingsManagerProtocol {
    @Published var currencyPreference: CurrencyPreference = .usd
    @Published var dataRefreshInterval: DataRefreshInterval = .live
    @Published var watchlistSorting: WatchlistSortingPreference = .marketCap
    
    func resetToDefaults() {
        currencyPreference = .usd
        dataRefreshInterval = .live
        watchlistSorting = .marketCap
    }
    
    func getCurrentRefreshInterval() -> TimeInterval? {
        return dataRefreshInterval.seconds
    }
    
    func shouldAutoRefresh() -> Bool {
        return true // Always auto-refresh since all options are automatic
    }
} 