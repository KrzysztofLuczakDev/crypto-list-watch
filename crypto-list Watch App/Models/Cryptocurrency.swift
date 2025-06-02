//
//  Cryptocurrency.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

struct Cryptocurrency: Identifiable, Codable, Hashable {
    let id: String // Keep numeric id for API calls
    let nameid: String // Use this for favorites and identification
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(nameid) // Use nameid for hashing
    }
    
    static func == (lhs: Cryptocurrency, rhs: Cryptocurrency) -> Bool {
        return lhs.nameid == rhs.nameid // Use nameid for equality
    }
    
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
        return String(format: "%.2f%%", change)
    }
    
    var priceChangeColor: String {
        guard let change = priceChangePercentage24h else { return "gray" }
        return change >= 0 ? "green" : "red"
    }
} 