//
//  Cryptocurrency.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - Cryptocurrency Model

struct Cryptocurrency: Codable, Identifiable, Hashable {
    let id: String
    let nameid: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    let totalVolume: Double?
    
    // Use nameid as the primary identifier for favorites
    var favoriteId: String {
        return nameid
    }
    
    // CodingKeys for proper Codable conformance
    enum CodingKeys: String, CodingKey {
        case id
        case nameid
        case symbol
        case name
        case image
        case currentPrice
        case marketCap
        case marketCapRank
        case priceChangePercentage24h
        case totalVolume
    }
    
    // Initialize with optional values for compatibility
    init(id: String, nameid: String = "", symbol: String, name: String, image: String, currentPrice: Double, marketCap: Double?, marketCapRank: Int?, priceChangePercentage24h: Double?, totalVolume: Double? = nil) {
        self.id = id
        self.nameid = nameid.isEmpty ? id : nameid // Fallback to id if nameid is empty
        self.symbol = symbol
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.marketCap = marketCap
        self.marketCapRank = marketCapRank
        self.priceChangePercentage24h = priceChangePercentage24h
        self.totalVolume = totalVolume
    }
    
    // MARK: - Computed Properties
    
    var price: Double {
        return currentPrice
    }
    
    var change24h: Double {
        return priceChangePercentage24h ?? 0.0
    }
    
    var volume24h: Double {
        return totalVolume ?? 0.0
    }
    
    var rank: Int {
        return marketCapRank ?? 0
    }
    
    // MARK: - Formatting Methods
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = currentPrice < 1 ? 4 : 2
        return formatter.string(from: NSNumber(value: currentPrice)) ?? "$0.00"
    }
    
    var formattedMarketCap: String {
        guard let marketCap = marketCap else { return "N/A" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 1
        
        // Custom compact formatting for watchOS compatibility
        let value = marketCap
        if value >= 1_000_000_000_000 {
            let trillions = value / 1_000_000_000_000
            return "$\(String(format: "%.1fT", trillions))"
        } else if value >= 1_000_000_000 {
            let billions = value / 1_000_000_000
            return "$\(String(format: "%.1fB", billions))"
        } else if value >= 1_000_000 {
            let millions = value / 1_000_000
            return "$\(String(format: "%.1fM", millions))"
        } else if value >= 1_000 {
            let thousands = value / 1_000
            return "$\(String(format: "%.1fK", thousands))"
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "$0"
        }
    }
    
    var formattedPriceChange: String {
        guard let change = priceChangePercentage24h else { return "0.00%" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))%"
    }
    
    var priceChangeColor: String {
        guard let change = priceChangePercentage24h else { return "gray" }
        return change >= 0 ? "green" : "red"
    }
    
    // MARK: - Helper Methods
    
    func formattedPrice(in currency: CurrencyPreference) -> String {
        let convertedPrice = CurrencyConversionService.shared.convertFromUSD(currentPrice, to: currency)
        return CurrencyFormatter.formatPrice(convertedPrice, currency: currency)
    }
    
    func formattedMarketCap(in currency: CurrencyPreference) -> String {
        guard let marketCap = marketCap else { return "N/A" }
        let convertedMarketCap = CurrencyConversionService.shared.convertFromUSD(marketCap, to: currency)
        return CurrencyFormatter.formatLargeNumber(convertedMarketCap, currency: currency)
    }
    
    func formattedVolume(in currency: CurrencyPreference) -> String {
        guard let volume = totalVolume else { return "N/A" }
        let convertedVolume = CurrencyConversionService.shared.convertFromUSD(volume, to: currency)
        return CurrencyFormatter.formatLargeNumber(convertedVolume, currency: currency)
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(nameid) // Use nameid for hashing
    }
    
    static func == (lhs: Cryptocurrency, rhs: Cryptocurrency) -> Bool {
        return lhs.nameid == rhs.nameid // Use nameid for equality
    }
}

// MARK: - API Response Models

struct CryptocurrencyResponse: Codable {
    let data: [Cryptocurrency]
    let info: ResponseInfo
}

struct ResponseInfo: Codable {
    let coinsNum: Int
    let time: Int
}

// MARK: - Sample Data

extension Cryptocurrency {
    static let sampleData = Cryptocurrency(
        id: "90",
        nameid: "bitcoin",
        symbol: "btc",
        name: "Bitcoin",
        image: "",
        currentPrice: 45000.00,
        marketCap: 850000000000,
        marketCapRank: 1,
        priceChangePercentage24h: 2.5,
        totalVolume: 25000000000
    )
} 