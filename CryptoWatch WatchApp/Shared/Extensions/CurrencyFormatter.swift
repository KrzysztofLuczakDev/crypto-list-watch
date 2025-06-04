//
//  CurrencyFormatter.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - Currency Formatter

struct CurrencyFormatter {
    
    // MARK: - Static Properties
    
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    private static let largeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 0.01 // Convert percentage values (e.g., 2.5) to decimal (0.025) for proper % formatting
        return formatter
    }()
    
    private static let compactFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - Public Methods
    
    /// Format price with appropriate currency symbol and precision
    static func formatPrice(_ price: Double, currency: CurrencyPreference) -> String {
        priceFormatter.currencySymbol = currency.symbol
        
        // Adjust decimal places based on price magnitude
        if price < 0.01 {
            priceFormatter.maximumFractionDigits = 8
        } else if price < 1 {
            priceFormatter.maximumFractionDigits = 6
        } else if price < 100 {
            priceFormatter.maximumFractionDigits = 4
        } else {
            priceFormatter.maximumFractionDigits = 2
        }
        
        return priceFormatter.string(from: NSNumber(value: price)) ?? "\(currency.symbol)0.00"
    }
    
    /// Format large numbers (market cap, volume) with appropriate suffixes
    static func formatLargeNumber(_ number: Double, currency: CurrencyPreference) -> String {
        largeNumberFormatter.currencySymbol = currency.symbol
        
        let absNumber = abs(number)
        
        if absNumber >= 1_000_000_000_000 { // Trillions
            let formatted = largeNumberFormatter.string(from: NSNumber(value: number / 1_000_000_000_000)) ?? "0"
            return "\(formatted)T"
        } else if absNumber >= 1_000_000_000 { // Billions
            let formatted = largeNumberFormatter.string(from: NSNumber(value: number / 1_000_000_000)) ?? "0"
            return "\(formatted)B"
        } else if absNumber >= 1_000_000 { // Millions
            let formatted = largeNumberFormatter.string(from: NSNumber(value: number / 1_000_000)) ?? "0"
            return "\(formatted)M"
        } else if absNumber >= 1_000 { // Thousands
            let formatted = largeNumberFormatter.string(from: NSNumber(value: number / 1_000)) ?? "0"
            return "\(formatted)K"
        } else {
            return largeNumberFormatter.string(from: NSNumber(value: number)) ?? "\(currency.symbol)0"
        }
    }
    
    /// Format percentage change with appropriate sign and color indication
    static func formatPercentageChange(_ percentage: Double) -> String {
        // Values are already in percentage format (e.g., 2.5 means 2.5%)
        let sign = percentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", percentage))%"
    }
    
    /// Format supply numbers with appropriate suffixes
    static func formatSupply(_ supply: Double) -> String {
        let absSupply = abs(supply)
        
        if absSupply >= 1_000_000_000_000 { // Trillions
            let formatted = compactFormatter.string(from: NSNumber(value: supply / 1_000_000_000_000)) ?? "0"
            return "\(formatted)T"
        } else if absSupply >= 1_000_000_000 { // Billions
            let formatted = compactFormatter.string(from: NSNumber(value: supply / 1_000_000_000)) ?? "0"
            return "\(formatted)B"
        } else if absSupply >= 1_000_000 { // Millions
            let formatted = compactFormatter.string(from: NSNumber(value: supply / 1_000_000)) ?? "0"
            return "\(formatted)M"
        } else if absSupply >= 1_000 { // Thousands
            let formatted = compactFormatter.string(from: NSNumber(value: supply / 1_000)) ?? "0"
            return "\(formatted)K"
        } else {
            return compactFormatter.string(from: NSNumber(value: supply)) ?? "0"
        }
    }
    
    /// Get color for percentage change
    static func colorForPercentageChange(_ percentage: Double) -> String {
        if percentage > 0 {
            return "green"
        } else if percentage < 0 {
            return "red"
        } else {
            return "gray"
        }
    }
    
    /// Format rank with ordinal suffix
    static func formatRank(_ rank: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: rank)) ?? "#\(rank)"
    }
    
    /// Format time interval for cache/update information
    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Extensions

extension Double {
    /// Convenience method to format as price
    func formatAsPrice(in currency: CurrencyPreference) -> String {
        return CurrencyFormatter.formatPrice(self, currency: currency)
    }
    
    /// Convenience method to format as large number
    func formatAsLargeNumber(in currency: CurrencyPreference) -> String {
        return CurrencyFormatter.formatLargeNumber(self, currency: currency)
    }
    
    /// Convenience method to format as percentage
    func formatAsPercentage() -> String {
        return CurrencyFormatter.formatPercentageChange(self)
    }
    
    /// Convenience method to format as supply
    func formatAsSupply() -> String {
        return CurrencyFormatter.formatSupply(self)
    }
    
    /// Format as currency with specific currency preference (with proper conversion)
    func formatAsCurrency(currency: CurrencyPreference) -> String {
        let convertedPrice = CurrencyConversionService.shared.convertFromUSD(self, to: currency)
        return CurrencyFormatter.formatPrice(convertedPrice, currency: currency)
    }
} 