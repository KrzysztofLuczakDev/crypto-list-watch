//
//  CoinGeckoConstants.swift
//  crypto-list
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

/// Central configuration and constants for CoinGecko API integration
/// This struct contains all the configuration values, endpoints, and utility methods
/// needed to interact with the CoinGecko API consistently across the app
struct CoinGeckoConstants {
    
    // MARK: - API Configuration
    
    /// Base URL for CoinGecko API v3
    /// Example: "https://api.coingecko.com/api/v3"
    /// All API endpoints are appended to this base URL
    static let baseURL = "https://api.coingecko.com/api/v3"
    
    /// User agent string sent with all HTTP requests
    /// Example: "CryptoList-watchOS/1.0"
    /// Helps CoinGecko identify our app in their logs and analytics
    static let userAgent = "CryptoList-watchOS/1.0"
    
    // MARK: - Pagination Configuration
    
    /// Default number of items to fetch per API request
    /// Example: 25 items per page provides good balance of data and performance
    /// Optimized for watchOS to avoid overwhelming the small screen
    static let defaultItemsPerPage = 25
    
    /// Maximum total items to load across all pages
    /// Example: 100 total items prevents infinite scrolling on limited watchOS storage
    /// Keeps memory usage reasonable while providing comprehensive data
    static let maxTotalItems = 100
    
    // MARK: - Network Configuration
    
    /// Maximum number of retry attempts for failed requests
    /// Example: If a request fails due to network issues, retry up to 3 times
    /// Improves reliability on unstable watchOS network connections
    static let maxRetries = 3
    
    /// Maximum number of retry attempts for failed requests (alias for compatibility)
    /// Example: If a request fails due to network issues, retry up to 3 times
    /// Improves reliability on unstable watchOS network connections
    static let maxRetryAttempts = 3
    
    /// Maximum delay between retry attempts in seconds
    /// Example: 8.0 seconds prevents excessive waiting while allowing network recovery
    /// Balances user experience with network resilience
    static let maxRetryDelay: TimeInterval = 8.0
    
    /// Maximum API requests allowed per minute for CoinGecko free tier
    /// Example: 25 requests/minute = ~2.4 seconds between requests
    /// Prevents hitting rate limits that would result in 429 errors
    static let maxRequestsPerMinute = 25
    
    /// Timeout for individual HTTP requests in seconds
    /// Example: If a request takes longer than 30 seconds, it will be cancelled
    /// Prevents the app from hanging on slow network connections
    static let requestTimeout: TimeInterval = 30.0
    
    /// Timeout for complete resource download in seconds
    /// Example: Total time allowed for request + response + data transfer
    /// Handles cases where data transfer is slow but connection is established
    static let resourceTimeout: TimeInterval = 120.0
    
    /// Maximum simultaneous HTTP connections to CoinGecko servers
    /// Example: Only 2 requests can be active at the same time
    /// Optimized for watchOS to balance performance and resource usage
    static let maxConnectionsPerHost = 2
    
    // MARK: - Cache Configuration
    
    /// Maximum number of cached API responses
    /// Example: Cache can hold responses for 100 different API calls
    /// Prevents unlimited cache growth that could consume device memory
    static let cacheCountLimit = 100
    
    /// Maximum cache size in bytes (10MB)
    /// Example: 10 * 1024 * 1024 = 10,485,760 bytes
    /// Limits memory usage while allowing reasonable caching on watchOS
    static let cacheSizeLimit = 10 * 1024 * 1024
    
    /// Cache key prefixes for different types of API responses
    /// Example: "top_cryptos_10" for top 10 coins, "cryptos_by_ids_12345" for specific coins
    /// Organizes cache entries and prevents key collisions between different data types
    struct CacheKeys {
        /// Prefix for top cryptocurrencies cache entries
        /// Example: "top_cryptos_10" caches the top 10 cryptocurrencies
        static let topCryptos = "top_cryptos"
        
        /// Prefix for paginated top cryptocurrencies cache entries
        /// Example: "top_cryptos_page_2_limit_10" caches page 2 with 10 items per page
        static let topCryptosPage = "top_cryptos_page"
        
        /// Prefix for specific cryptocurrencies fetched by their IDs
        /// Example: "cryptos_by_ids_bitcoin,ethereum" caches Bitcoin and Ethereum data
        static let cryptosByIds = "cryptos_by_ids"
        
        /// Prefix for search results cache entries
        /// Example: "search_results_bitcoin" caches search results for "bitcoin"
        static let searchResults = "search_results"
    }
    
    // MARK: - Search Configuration
    
    /// Minimum number of characters required to trigger a search
    /// Example: User must type at least "bi" before searching for "bitcoin"
    /// Prevents excessive API calls for single character searches
    static let minSearchQueryLength = 2
    
    /// Delay in nanoseconds before executing search after user stops typing
    /// Example: 300,000,000 nanoseconds = 0.3 seconds
    /// Prevents API calls on every keystroke, waits for user to finish typing
    static let searchDebounceDelay: UInt64 = 300_000_000 // 0.3 seconds
    
    /// Maximum number of search results to return
    /// Example: Even if CoinGecko returns 50 matches, only show first 10
    /// Keeps search results manageable on small watchOS screen
    static let maxSearchResults = 10
    
    // MARK: - UI Configuration
    
    /// Scale factor for loading progress indicators
    /// Example: 0.6 makes loading spinners 60% of their default size
    /// Optimizes loading indicators for watchOS screen size
    static let loadingIndicatorScale = 0.6
    
    /// Duration for UI animations in seconds
    /// Example: Search bar slide-in animation takes 0.3 seconds
    /// Provides smooth, responsive feel without being too slow or jarring
    static let animationDuration = 0.3
    
    // MARK: - Error Messages
    
    /// User-friendly error messages for different failure scenarios
    /// Example: Instead of "NSURLErrorNotConnectedToInternet", show "No internet connection..."
    /// Provides consistent, helpful error messages throughout the app
    struct ErrorMessages {
        /// Shown when device has no internet connectivity
        /// Example: Airplane mode is on, WiFi is disconnected
        static let noInternet = "No internet connection. Please check your network settings."
        
        /// Shown when CoinGecko servers are experiencing issues
        /// Example: HTTP 500, 502, 503 errors from the API
        static let serverUnavailable = "Server is temporarily unavailable. Please try again later."
        
        /// Shown when API access is denied or forbidden
        /// Example: HTTP 401, 403 errors indicating authentication/authorization issues
        static let accessDenied = "Access denied. Please check your API configuration."
        
        /// Shown when rate limits are exceeded
        /// Example: Too many requests sent, need to wait before trying again
        static let rateLimitExceeded = "Too many requests. Please wait before trying again."
        
        /// Generic fallback error message for unexpected issues
        /// Example: Parsing errors, unknown HTTP status codes
        static let unknownError = "An unexpected error occurred. Please try again."
    }
    
    // MARK: - API Endpoints
    
    /// CoinGecko API endpoint paths
    /// Example: baseURL + markets = "https://api.coingecko.com/api/v3/coins/markets"
    /// Centralizes endpoint definitions for easy maintenance
    struct Endpoints {
        /// Endpoint for cryptocurrency market data
        /// Example: "/coins/markets" - returns price, market cap, volume data
        static let markets = "/coins/markets"
        
        /// Endpoint for searching cryptocurrencies
        /// Example: "/search" - finds coins matching a search query
        static let search = "/search"
        
        /// Endpoint for API health checks
        /// Example: "/ping" - verifies API is responding
        static let ping = "/ping"
    }
    
    // MARK: - Query Parameters
    
    /// Standard query parameters used across API requests
    /// Example: "?vs_currency=usd&order=market_cap_desc" for USD prices sorted by market cap
    /// Ensures consistent data format and sorting across the app
    struct QueryParams {
        /// Default currency for price data
        /// Example: "usd" returns prices in US Dollars
        static let defaultVsCurrency = "usd"
        
        /// Sorting order for cryptocurrency lists
        /// Example: "market_cap_desc" sorts by market capitalization, highest first
        static let order = "market_cap_desc"
        
        /// Whether to include price sparkline data
        /// Example: "false" excludes 7-day price charts to reduce response size
        static let sparkline = "false"
        
        /// Time period for price change percentage
        /// Example: "24h" shows price change over the last 24 hours
        static let priceChangePercentage = "24h"
    }
}

// MARK: - Computed Properties

extension CoinGeckoConstants {
    
    /// Constructs complete URL for markets endpoint with pagination
    /// Example: marketsURL(page: 2, limit: 10, currency: "usd") returns
    /// "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=2&sparkline=false&price_change_percentage=24h"
    /// - Parameters:
    ///   - page: Page number (1-based) for pagination
    ///   - limit: Number of items per page
    ///   - currency: Currency for price data (defaults to USD)
    /// - Returns: Complete URL string ready for HTTP request
    static func marketsURL(page: Int, limit: Int, currency: String = QueryParams.defaultVsCurrency) -> String {
        return "\(baseURL)\(Endpoints.markets)?vs_currency=\(currency)&order=\(QueryParams.order)&per_page=\(limit)&page=\(page)&sparkline=\(QueryParams.sparkline)&price_change_percentage=\(QueryParams.priceChangePercentage)"
    }
    
    /// Constructs complete URL for markets endpoint with specific cryptocurrency IDs
    /// Example: marketsURLByIds(ids: ["bitcoin", "ethereum"], currency: "eur") returns
    /// "https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur&ids=bitcoin,ethereum&order=market_cap_desc&per_page=2&page=1&sparkline=false&price_change_percentage=24h"
    /// - Parameters:
    ///   - ids: Array of cryptocurrency IDs
    ///   - currency: Currency for price data (defaults to USD)
    /// - Returns: Complete URL string ready for HTTP request
    static func marketsURLByIds(ids: [String], currency: String = QueryParams.defaultVsCurrency) -> String {
        let idsString = ids.joined(separator: ",")
        return "\(baseURL)\(Endpoints.markets)?vs_currency=\(currency)&ids=\(idsString)&order=\(QueryParams.order)&per_page=\(ids.count)&page=1&sparkline=\(QueryParams.sparkline)&price_change_percentage=\(QueryParams.priceChangePercentage)"
    }
    
    /// Constructs complete URL for search endpoint
    /// Example: searchURL(query: "bitcoin") returns
    /// "https://api.coingecko.com/api/v3/search?query=bitcoin"
    /// - Parameter query: Search term (automatically URL-encoded)
    /// - Returns: Complete URL string ready for HTTP request
    static func searchURL(query: String) -> String {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "\(baseURL)\(Endpoints.search)?query=\(encodedQuery)"
    }
    
    /// Generates cache key for top cryptocurrencies
    /// Example: topCryptosCacheKey(limit: 10, currency: "usd") returns "top_cryptos_10_usd"
    /// - Parameters:
    ///   - limit: Number of top coins
    ///   - currency: Currency for price data
    /// - Returns: Unique cache key string
    static func topCryptosCacheKey(limit: Int, currency: String = QueryParams.defaultVsCurrency) -> String {
        return "\(CacheKeys.topCryptos)_\(limit)_\(currency)"
    }
    
    /// Generates cache key for paginated top cryptocurrencies
    /// Example: topCryptosPageCacheKey(page: 2, limit: 10, currency: "eur") returns "top_cryptos_page_2_limit_10_eur"
    /// - Parameters:
    ///   - page: Page number
    ///   - limit: Items per page
    ///   - currency: Currency for price data
    /// - Returns: Unique cache key string
    static func topCryptosPageCacheKey(page: Int, limit: Int, currency: String = QueryParams.defaultVsCurrency) -> String {
        return "\(CacheKeys.topCryptosPage)_\(page)_limit_\(limit)_\(currency)"
    }
    
    /// Generates cache key for cryptocurrencies fetched by specific IDs
    /// Example: cryptosByIdsCacheKey(ids: ["bitcoin", "ethereum"], currency: "btc") returns "cryptos_by_ids_12345_btc"
    /// (where 12345 is the hash of the joined IDs)
    /// - Parameters:
    ///   - ids: Array of cryptocurrency IDs
    ///   - currency: Currency for price data
    /// - Returns: Unique cache key string based on ID combination and currency
    static func cryptosByIdsCacheKey(ids: [String], currency: String = QueryParams.defaultVsCurrency) -> String {
        let idsString = ids.joined(separator: ",")
        return "\(CacheKeys.cryptosByIds)_\(idsString.hashValue)_\(currency)"
    }
} 