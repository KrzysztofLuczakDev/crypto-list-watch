//
//  CurrencyFormatter.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

extension NumberFormatter {
    
    /// Creates a currency formatter configured for the specified currency preference
    /// - Parameter currency: The currency preference to format for
    /// - Returns: A configured NumberFormatter
    static func currencyFormatter(for currency: CurrencyPreference) -> NumberFormatter {
        let formatter = NumberFormatter()
        
        switch currency {
        // Major Global Currencies
        case .usd:
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.currencySymbol = "$"
        case .eur:
            formatter.numberStyle = .currency
            formatter.currencyCode = "EUR"
            formatter.currencySymbol = "€"
        case .gbp:
            formatter.numberStyle = .currency
            formatter.currencyCode = "GBP"
            formatter.currencySymbol = "£"
        case .jpy:
            formatter.numberStyle = .currency
            formatter.currencyCode = "JPY"
            formatter.currencySymbol = "¥"
            formatter.maximumFractionDigits = 0 // JPY doesn't use decimal places
        case .cad:
            formatter.numberStyle = .currency
            formatter.currencyCode = "CAD"
            formatter.currencySymbol = "C$"
        case .aud:
            formatter.numberStyle = .currency
            formatter.currencyCode = "AUD"
            formatter.currencySymbol = "A$"
        case .chf:
            formatter.numberStyle = .currency
            formatter.currencyCode = "CHF"
            formatter.currencySymbol = "CHF"
        case .cny:
            formatter.numberStyle = .currency
            formatter.currencyCode = "CNY"
            formatter.currencySymbol = "¥"
            
        // European Currencies
        case .nok:
            formatter.numberStyle = .currency
            formatter.currencyCode = "NOK"
            formatter.currencySymbol = "kr"
        case .sek:
            formatter.numberStyle = .currency
            formatter.currencyCode = "SEK"
            formatter.currencySymbol = "kr"
        case .dkk:
            formatter.numberStyle = .currency
            formatter.currencyCode = "DKK"
            formatter.currencySymbol = "kr"
        case .pln:
            formatter.numberStyle = .currency
            formatter.currencyCode = "PLN"
            formatter.currencySymbol = "zł"
        case .czk:
            formatter.numberStyle = .currency
            formatter.currencyCode = "CZK"
            formatter.currencySymbol = "Kč"
        case .huf:
            formatter.numberStyle = .currency
            formatter.currencyCode = "HUF"
            formatter.currencySymbol = "Ft"
            formatter.maximumFractionDigits = 0 // HUF typically doesn't use decimal places
        case .ron:
            formatter.numberStyle = .currency
            formatter.currencyCode = "RON"
            formatter.currencySymbol = "lei"
        case .bgn:
            formatter.numberStyle = .currency
            formatter.currencyCode = "BGN"
            formatter.currencySymbol = "лв"
        case .hrk:
            formatter.numberStyle = .currency
            formatter.currencyCode = "HRK"
            formatter.currencySymbol = "kn"
        case .rsd:
            formatter.numberStyle = .currency
            formatter.currencyCode = "RSD"
            formatter.currencySymbol = "дин"
        case .isk:
            formatter.numberStyle = .currency
            formatter.currencyCode = "ISK"
            formatter.currencySymbol = "kr"
            formatter.maximumFractionDigits = 0 // ISK typically doesn't use decimal places
        case .try_:
            formatter.numberStyle = .currency
            formatter.currencyCode = "TRY"
            formatter.currencySymbol = "₺"
        case .rub:
            formatter.numberStyle = .currency
            formatter.currencyCode = "RUB"
            formatter.currencySymbol = "₽"
        case .uah:
            formatter.numberStyle = .currency
            formatter.currencyCode = "UAH"
            formatter.currencySymbol = "₴"
            
        // Cryptocurrencies
        case .btc:
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 8
        case .eth:
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 6
        case .bnb, .ada, .dot, .sol:
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 4
        }
        
        return formatter
    }
}

extension Double {
    
    /// Formats the double value as a currency string based on user preferences
    /// - Parameter currency: The currency preference to use for formatting
    /// - Returns: A formatted currency string
    func formatAsCurrency(currency: CurrencyPreference = SettingsManager.shared.currencyPreference) -> String {
        // Convert from USD to target currency if needed
        let convertedValue: Double
        if currency == .usd {
            convertedValue = self
        } else {
            convertedValue = CurrencyConversionService.shared.convertFromUSD(self, to: currency)
        }
        
        let formatter = NumberFormatter.currencyFormatter(for: currency)
        
        switch currency {
        case .usd, .eur, .gbp, .cad, .aud, .chf, .cny, .nok, .sek, .dkk, .pln, .czk, .ron, .bgn, .hrk, .rsd, .try_, .rub, .uah:
            // For most fiat currencies, adjust decimal places based on value
            formatter.maximumFractionDigits = convertedValue < 1 ? 4 : 2
            return formatter.string(from: NSNumber(value: convertedValue)) ?? "\(currency.symbol)0.00"
            
        case .jpy, .huf, .isk:
            // These currencies typically don't use decimal places
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: convertedValue)) ?? "\(currency.symbol)0"
            
        case .btc, .eth, .bnb, .ada, .dot, .sol:
            // For crypto currencies, use custom formatting
            let formatted = formatter.string(from: NSNumber(value: convertedValue)) ?? "0"
            return "\(currency.symbol)\(formatted)"
        }
    }
    
    /// Formats the double value as a percentage string
    /// - Returns: A formatted percentage string
    func formatAsPercentage() -> String {
        return String(format: "%.2f%%", self)
    }
}

extension Optional where Wrapped == Double {
    
    /// Formats the optional double value as a currency string
    /// - Parameter currency: The currency preference to use for formatting
    /// - Returns: A formatted currency string or "N/A" if nil
    func formatAsCurrency(currency: CurrencyPreference = SettingsManager.shared.currencyPreference) -> String {
        guard let value = self else { return "N/A" }
        return value.formatAsCurrency(currency: currency)
    }
    
    /// Formats the optional double value as a percentage string
    /// - Returns: A formatted percentage string or "N/A" if nil
    func formatAsPercentage() -> String {
        guard let value = self else { return "N/A" }
        return value.formatAsPercentage()
    }
} 