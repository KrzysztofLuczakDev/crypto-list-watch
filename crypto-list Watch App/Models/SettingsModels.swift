//
//  SettingsModels.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - Currency Preference
enum CurrencyPreference: String, CaseIterable {
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
}

// MARK: - Data Refresh Interval
enum DataRefreshInterval: String, CaseIterable {
    case tenSeconds = "10"
    case thirtySeconds = "30"
    case oneMinute = "60"
    case fiveMinutes = "300"
    case manual = "manual"
    
    var displayName: String {
        switch self {
        case .tenSeconds: return "10 seconds"
        case .thirtySeconds: return "30 seconds"
        case .oneMinute: return "1 minute"
        case .fiveMinutes: return "5 minutes"
        case .manual: return "Manual"
        }
    }
    
    var seconds: TimeInterval? {
        switch self {
        case .tenSeconds: return 10
        case .thirtySeconds: return 30
        case .oneMinute: return 60
        case .fiveMinutes: return 300
        case .manual: return nil
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

// MARK: - Default Chart Time Range
enum DefaultChartTimeRange: String, CaseIterable {
    case oneHour = "1h"
    case oneDay = "1d"
    case oneWeek = "7d"
    case oneMonth = "30d"
    case threeMonths = "90d"
    case oneYear = "365d"
    
    var displayName: String {
        switch self {
        case .oneHour: return "1 Hour"
        case .oneDay: return "1 Day"
        case .oneWeek: return "1 Week"
        case .oneMonth: return "1 Month"
        case .threeMonths: return "3 Months"
        case .oneYear: return "1 Year"
        }
    }
} 