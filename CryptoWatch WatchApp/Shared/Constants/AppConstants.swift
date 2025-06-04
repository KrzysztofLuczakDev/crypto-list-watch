//
//  AppConstants.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - App Constants

struct AppConstants {
    
    // MARK: - API Configuration
    
    struct API {
        static let baseURL = "https://api.coinlore.net/api"
        static let requestTimeout: TimeInterval = 30
        static let resourceTimeout: TimeInterval = 60
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 1.0
    }
    
    // MARK: - Cache Configuration
    
    struct Cache {
        static let defaultExpirationTime: TimeInterval = 300 // 5 minutes
        static let shortExpirationTime: TimeInterval = 30 // 30 seconds
        static let longExpirationTime: TimeInterval = 3600 // 1 hour
        static let maxCacheSize = 50 // Maximum number of cached items
    }
    
    // MARK: - UI Constants
    
    struct UI {
        static let animationDuration: TimeInterval = 0.3
        static let cornerRadius: CGFloat = 8.0
        static let smallCornerRadius: CGFloat = 6.0
        static let defaultPadding: CGFloat = 12.0
        static let smallPadding: CGFloat = 8.0
        static let minimumTapTarget: CGFloat = 44.0
    }
    
    // MARK: - Pagination
    
    struct Pagination {
        static let defaultPageSize = 50
        static let maxPageSize = 100
        static let loadMoreThreshold = 10 // Load more when within 10 items of end
    }
    
    // MARK: - Search
    
    struct Search {
        static let minimumQueryLength = 2
        static let searchDelay: TimeInterval = 0.3 // Debounce delay
        static let maxResults = 50
    }
    
    // MARK: - Accessibility
    
    struct Accessibility {
        static let searchFieldIdentifier = "searchField"
        static let settingsButtonIdentifier = "settingsButton"
        static let favoriteButtonIdentifier = "favoriteButton"
        static let cryptoRowIdentifier = "cryptoRow"
        static let refreshButtonIdentifier = "refreshButton"
    }
    
    // MARK: - User Defaults Keys
    
    struct UserDefaultsKeys {
        static let currencyPreference = "currency_preference"
        static let dataRefreshInterval = "data_refresh_interval"
        static let watchlistSorting = "watchlist_sorting"
        static let favoriteCryptocurrencies = "FavoriteCryptocurrencies"
        static let hasSeenOnboarding = "has_seen_onboarding"
        static let lastUpdateTime = "last_update_time"
    }
    
    // MARK: - App Groups
    
    struct AppGroups {
        static let suiteName = "group.krzysztof-luczak.crypto-watch"
    }
    
    // MARK: - Notifications
    
    struct Notifications {
        static let settingsDidChange = "settingsDidChange"
        static let favoritesDidChange = "favoritesDidChange"
        static let dataDidUpdate = "dataDidUpdate"
        static let networkStatusDidChange = "networkStatusDidChange"
    }
    
    // MARK: - Limits
    
    struct Limits {
        static let maxFavorites = 50
        static let maxSearchHistory = 10
        static let maxCacheAge: TimeInterval = 86400 // 24 hours
    }
    
    // MARK: - URLs
    
    struct URLs {
        static let privacyPolicy = "https://example.com/privacy"
        static let termsOfService = "https://example.com/terms"
        static let supportEmail = "support@example.com"
        static let appStoreURL = "https://apps.apple.com/app/crypto-watch"
    }
    
    // MARK: - App Information
    
    struct AppInfo {
        static let name = "Crypto Watch"
        static let version = "1.0.0"
        static let buildNumber = "1"
        static let developer = "Krzysztof Łuczak"
        static let copyright = "© 2025 Krzysztof Łuczak"
    }
    
    // MARK: - Feature Flags
    
    struct FeatureFlags {
        static let enableAdvancedCharts = false
        static let enablePushNotifications = false
        static let enableWidgetSupport = true
        static let enableDebugMode = false
    }
} 