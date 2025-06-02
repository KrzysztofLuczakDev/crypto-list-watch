//
//  SettingsManager.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    // Use App Groups for sharing data between app and widget
    private let userDefaults = UserDefaults(suiteName: "group.krzysztof-luczak.crypto-list") ?? UserDefaults.standard
    
    // MARK: - Settings Keys
    private struct Keys {
        static let currency = "currency_preference"
        static let dataRefreshInterval = "data_refresh_interval"
        static let watchlistSorting = "watchlist_sorting"
        static let defaultChartTimeRange = "default_chart_time_range"
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
    
    @Published var defaultChartTimeRange: DefaultChartTimeRange {
        didSet { 
            saveDefaultChartTimeRange()
            postSettingsChangeNotification()
        }
    }
    
    private init() {
        // Load saved settings or use defaults
        self.currencyPreference = CurrencyPreference(rawValue: userDefaults.string(forKey: Keys.currency) ?? "") ?? .usd
        self.dataRefreshInterval = DataRefreshInterval(rawValue: userDefaults.string(forKey: Keys.dataRefreshInterval) ?? "") ?? .thirtySeconds
        self.watchlistSorting = WatchlistSortingPreference(rawValue: userDefaults.string(forKey: Keys.watchlistSorting) ?? "") ?? .marketCap
        self.defaultChartTimeRange = DefaultChartTimeRange(rawValue: userDefaults.string(forKey: Keys.defaultChartTimeRange) ?? "") ?? .oneDay
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
    
    private func saveDefaultChartTimeRange() {
        userDefaults.set(defaultChartTimeRange.rawValue, forKey: Keys.defaultChartTimeRange)
    }
    
    private func postSettingsChangeNotification() {
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    // MARK: - Reset Methods
    func resetToDefaults() {
        currencyPreference = .usd
        dataRefreshInterval = .thirtySeconds
        watchlistSorting = .marketCap
        defaultChartTimeRange = .oneDay
    }
    
    // MARK: - Utility Methods
    func getCurrentRefreshInterval() -> TimeInterval? {
        return dataRefreshInterval.seconds
    }
    
    func shouldAutoRefresh() -> Bool {
        return dataRefreshInterval != .manual
    }
} 