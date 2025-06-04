//
//  CryptoWidget.swift
//  Crypto Watch Widget Extension
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import WidgetKit
import SwiftUI

struct CryptoWidget: Widget {
    let kind: String = "CryptoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CryptoTimelineProvider()) { entry in
            CryptoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Crypto Tracker")
        .description("Track your favorite cryptocurrencies")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryCorner])
    }
}

struct CryptoTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CryptoEntry {
        CryptoEntry(date: Date(), cryptocurrencies: sampleCryptos)
    }

    func getSnapshot(in context: Context, completion: @escaping (CryptoEntry) -> ()) {
        let entry = CryptoEntry(date: Date(), cryptocurrencies: sampleCryptos)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do {
                let cryptos = try await fetchCryptocurrencies()
                let entry = CryptoEntry(date: Date(), cryptocurrencies: cryptos)
                
                // Update every 15 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                
                completion(timeline)
            } catch {
                // Fallback to sample data on error
                let entry = CryptoEntry(date: Date(), cryptocurrencies: sampleCryptos)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                
                completion(timeline)
            }
        }
    }
    
    private func fetchCryptocurrencies() async throws -> [CryptocurrencyData] {
        // Check if user has favorites first
        let favoritesManager = FavoritesManager.shared
        let favoriteNameids = favoritesManager.getFavoriteNameidsList()
        
        let coinLoreService = CoinLoreService.shared
        
        // Get user's currency preference (default to USD for widget)
        let settingsManager = SettingsManager.shared
        let currency = settingsManager.currencyPreference
        
        if !favoriteNameids.isEmpty {
            // Fetch favorites (limit to 3 for widget)
            let limitedNameids = Array(favoriteNameids.prefix(3))
            let cryptos = try await coinLoreService.fetchCryptocurrenciesByNameids(nameids: limitedNameids)
            return cryptos.map { CryptocurrencyData(from: $0, currency: currency) }
        } else {
            // Fetch top 3 cryptocurrencies
            let cryptos = try await coinLoreService.fetchTopCryptocurrencies(start: 0, limit: 3)
            return cryptos.map { CryptocurrencyData(from: $0, currency: currency) }
        }
    }
}

struct CryptoEntry: TimelineEntry {
    let date: Date
    let cryptocurrencies: [CryptocurrencyData]
}

// Simplified data structure for widget
struct CryptocurrencyData {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let priceChangePercentage24h: Double?
    let currency: CurrencyPreference
    
    init(from crypto: Cryptocurrency, currency: CurrencyPreference = .usd) {
        self.id = crypto.id
        self.symbol = crypto.symbol
        self.name = crypto.name
        self.currentPrice = crypto.currentPrice
        self.priceChangePercentage24h = crypto.priceChangePercentage24h
        self.currency = currency
    }
    
    var formattedPrice: String {
        // Convert USD price to target currency
        let convertedPrice = CurrencyConversionService.shared.convertFromUSD(currentPrice, to: currency)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency.symbol
        
        // Adjust decimal places based on price magnitude and currency type
        if currency.isCrypto {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = currency == .btc ? 8 : 6
            let formatted = formatter.string(from: NSNumber(value: convertedPrice)) ?? "0"
            return "\(currency.symbol)\(formatted)"
        } else {
            if convertedPrice < 0.01 {
                formatter.maximumFractionDigits = 8
            } else if convertedPrice < 1 {
                formatter.maximumFractionDigits = 6
            } else if convertedPrice < 100 {
                formatter.maximumFractionDigits = 4
            } else {
                formatter.maximumFractionDigits = 2
            }
            return formatter.string(from: NSNumber(value: convertedPrice)) ?? "\(currency.symbol)0.00"
        }
    }
    
    var formattedPriceChange: String {
        guard let change = priceChangePercentage24h else { return "0.00%" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))%"
    }
    
    var isPositiveChange: Bool {
        return (priceChangePercentage24h ?? 0) >= 0
    }
}

// Sample data for previews and placeholders
let sampleCryptos = [
    CryptocurrencyData(
        from: Cryptocurrency(
            id: "90",
            nameid: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            image: "",
            currentPrice: 45000.0,
            marketCap: 850000000000,
            marketCapRank: 1,
            priceChangePercentage24h: 2.5
        )
    ),
    CryptocurrencyData(
        from: Cryptocurrency(
            id: "80",
            nameid: "ethereum",
            symbol: "eth",
            name: "Ethereum",
            image: "",
            currentPrice: 3200.0,
            marketCap: 380000000000,
            marketCapRank: 2,
            priceChangePercentage24h: -1.2
        )
    ),
    CryptocurrencyData(
        from: Cryptocurrency(
            id: "257",
            nameid: "cardano",
            symbol: "ada",
            name: "Cardano",
            image: "",
            currentPrice: 0.45,
            marketCap: 15000000000,
            marketCapRank: 8,
            priceChangePercentage24h: 5.8
        )
    )
] 