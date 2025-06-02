//
//  CryptoWidget.swift
//  crypto-list Widget Extension
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
        let favoriteIds = favoritesManager.getFavoritesList()
        
        let coinGeckoService = CoinGeckoService.shared
        
        if !favoriteIds.isEmpty {
            // Fetch favorites (limit to 3 for widget)
            let limitedIds = Array(favoriteIds.prefix(3))
            let cryptos = try await coinGeckoService.fetchCryptocurrenciesByIds(limitedIds)
            return cryptos.map { CryptocurrencyData(from: $0) }
        } else {
            // Fetch top 3 cryptocurrencies
            let cryptos = try await coinGeckoService.fetchTopCryptocurrencies(limit: 3)
            return cryptos.map { CryptocurrencyData(from: $0) }
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
    
    init(from crypto: Cryptocurrency) {
        self.id = crypto.id
        self.symbol = crypto.symbol
        self.name = crypto.name
        self.currentPrice = crypto.currentPrice
        self.priceChangePercentage24h = crypto.priceChangePercentage24h
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = currentPrice < 1 ? 4 : 2
        return formatter.string(from: NSNumber(value: currentPrice)) ?? "$0.00"
    }
    
    var formattedPriceChange: String {
        guard let change = priceChangePercentage24h else { return "0.00%" }
        return String(format: "%.2f%%", change)
    }
    
    var isPositiveChange: Bool {
        return (priceChangePercentage24h ?? 0) >= 0
    }
}

// Sample data for previews and placeholders
let sampleCryptos = [
    CryptocurrencyData(
        from: Cryptocurrency(
            id: "bitcoin",
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
            id: "ethereum",
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
            id: "cardano",
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