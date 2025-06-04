//
//  AppModels.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - Currency Preferences

enum CurrencyPreference: String, CaseIterable, Codable {
    // Major Global Currencies
    case usd = "usd"
    case eur = "eur"
    case gbp = "gbp"
    case jpy = "jpy"
    case cad = "cad"
    case aud = "aud"
    case chf = "chf"
    case cny = "cny"
    
    // European Currencies
    case nok = "nok"  // Norwegian Krone
    case sek = "sek"  // Swedish Krona
    case dkk = "dkk"  // Danish Krone
    case pln = "pln"  // Polish Złoty
    case czk = "czk"  // Czech Koruna
    case huf = "huf"  // Hungarian Forint
    case ron = "ron"  // Romanian Leu
    case bgn = "bgn"  // Bulgarian Lev
    case hrk = "hrk"  // Croatian Kuna
    case rsd = "rsd"  // Serbian Dinar
    case isk = "isk"  // Icelandic Króna
    case try_ = "try" // Turkish Lira (using try_ because try is a keyword)
    case rub = "rub"  // Russian Ruble
    case uah = "uah"  // Ukrainian Hryvnia
    
    // Cryptocurrencies
    case btc = "btc"
    case eth = "eth"
    case bnb = "bnb"
    case ada = "ada"
    case dot = "dot"
    case sol = "sol"
    
    var displayName: String {
        switch self {
        case .usd: return "USD"
        case .eur: return "EUR"
        case .gbp: return "GBP"
        case .jpy: return "JPY"
        case .cad: return "CAD"
        case .aud: return "AUD"
        case .chf: return "CHF"
        case .cny: return "CNY"
        case .nok: return "NOK"
        case .sek: return "SEK"
        case .dkk: return "DKK"
        case .pln: return "PLN"
        case .czk: return "CZK"
        case .huf: return "HUF"
        case .ron: return "RON"
        case .bgn: return "BGN"
        case .hrk: return "HRK"
        case .rsd: return "RSD"
        case .isk: return "ISK"
        case .try_: return "TRY"
        case .rub: return "RUB"
        case .uah: return "UAH"
        case .btc: return "BTC"
        case .eth: return "ETH"
        case .bnb: return "BNB"
        case .ada: return "ADA"
        case .dot: return "DOT"
        case .sol: return "SOL"
        }
    }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .cad: return "C$"
        case .aud: return "A$"
        case .chf: return "CHF"
        case .cny: return "¥"
        case .nok: return "kr"
        case .sek: return "kr"
        case .dkk: return "kr"
        case .pln: return "zł"
        case .czk: return "Kč"
        case .huf: return "Ft"
        case .ron: return "lei"
        case .bgn: return "лв"
        case .hrk: return "kn"
        case .rsd: return "дин"
        case .isk: return "kr"
        case .try_: return "₺"
        case .rub: return "₽"
        case .uah: return "₴"
        case .btc: return "₿"
        case .eth: return "Ξ"
        case .bnb: return "BNB"
        case .ada: return "₳"
        case .dot: return "DOT"
        case .sol: return "SOL"
        }
    }
    
    var isCrypto: Bool {
        switch self {
        case .btc, .eth, .bnb, .ada, .dot, .sol:
            return true
        default:
            return false
        }
    }
    
    var isEuropean: Bool {
        switch self {
        case .eur, .gbp, .chf, .nok, .sek, .dkk, .pln, .czk, .huf, .ron, .bgn, .hrk, .rsd, .isk, .try_, .rub, .uah:
            return true
        default:
            return false
        }
    }
    
    static var fiatCurrencies: [CurrencyPreference] {
        return allCases.filter { !$0.isCrypto }
    }
    
    static var cryptoCurrencies: [CurrencyPreference] {
        return allCases.filter { $0.isCrypto }
    }
}

// MARK: - Data Refresh Interval

enum DataRefreshInterval: String, CaseIterable {
    case live = "1"
    case thirtySeconds = "30"
    case oneMinute = "60"
    case fiveMinutes = "300"
    
    var displayName: String {
        switch self {
        case .live: return "Live"
        case .thirtySeconds: return "30 seconds"
        case .oneMinute: return "1 minute"
        case .fiveMinutes: return "5 minutes"
        }
    }
    
    var seconds: TimeInterval? {
        switch self {
        case .live: return 1
        case .thirtySeconds: return 30
        case .oneMinute: return 60
        case .fiveMinutes: return 300
        }
    }
}

// MARK: - Watchlist Sorting Preference

enum WatchlistSortingPreference: String, CaseIterable {
    case marketCap = "market_cap"
    case volume = "volume"
    case price = "price"
    case alphabetical = "alphabetical"
    case priceChange = "price_change"
    
    var displayName: String {
        switch self {
        case .marketCap: return "Market Cap"
        case .volume: return "Volume"
        case .price: return "Price"
        case .alphabetical: return "Alphabetical"
        case .priceChange: return "Price Change"
        }
    }
    
    var iconName: String {
        switch self {
        case .marketCap: return "chart.bar"
        case .volume: return "chart.bar.xaxis"
        case .price: return "dollarsign.circle"
        case .alphabetical: return "textformat.abc"
        case .priceChange: return "arrow.up.arrow.down"
        }
    }
}

// MARK: - App State

enum AppState {
    case loading
    case loaded
    case error(String)
    case empty
}

// MARK: - Tab Selection

enum TabSelection: Int, CaseIterable {
    case topCoins = 0
    case favorites = 1
    
    var title: String {
        switch self {
        case .topCoins: return "Top Coins"
        case .favorites: return "Favorites"
        }
    }
}

// MARK: - Sort Options

enum SortOption: String, CaseIterable {
    case rank = "rank"
    case name = "name"
    case price = "price"
    case change24h = "change24h"
    case marketCap = "marketCap"
    
    var displayName: String {
        switch self {
        case .rank: return "Rank"
        case .name: return "Name"
        case .price: return "Price"
        case .change24h: return "24h Change"
        case .marketCap: return "Market Cap"
        }
    }
}

// MARK: - Error Types

enum AppError: Error, LocalizedError {
    case networkError(String)
    case decodingError(String)
    case noData
    case invalidURL
    case timeout
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Data Error: \(message)"
        case .noData:
            return "No data available"
        case .invalidURL:
            return "Invalid URL"
        case .timeout:
            return "Request timeout"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
} 