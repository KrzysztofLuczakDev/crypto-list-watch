//
//  Cryptocurrency.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

struct Cryptocurrency: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double
    let marketCapRank: Int
    let priceChangePercentage24h: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = currentPrice < 1 ? 4 : 2
        return formatter.string(from: NSNumber(value: currentPrice)) ?? "$0.00"
    }
    
    var formattedMarketCap: String {
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