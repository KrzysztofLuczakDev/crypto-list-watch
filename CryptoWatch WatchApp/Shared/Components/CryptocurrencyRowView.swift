//
//  CryptocurrencyRowView.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct CryptocurrencyRowView: View {
    let cryptocurrency: Cryptocurrency
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    // Computed property for dynamic rank font size
    private var rankFontSize: CGFloat {
        guard let rank = cryptocurrency.marketCapRank else { return 7 }
        let rankString = String(rank)
        switch rankString.count {
        case 1: return 10  // Single digit (1-9)
        case 2: return 9  // Two digits (10-99)
        case 3: return 7   // Three digits (100-999)
        default: return 5  // Four or more digits (1000+)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            // Rank badge with dynamic font size
            Text("#\(cryptocurrency.marketCapRank ?? 0)")
                .font(.system(size: rankFontSize))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                // Name and Symbol with icon
                HStack {
                    Text("\(cryptocurrency.symbol.uppercased())/\(settingsManager.currencyPreference.displayName)")
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(formattedPercentageChange)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(priceChangeColor.opacity(0.9))
                }
                
                // Price with proper currency formatting and color coding
                HStack {
                    Text(formattedPrice)
                        .font(.system(size: 11))
                        .fontWeight(.semibold)
                        .foregroundColor(priceChangeColor)
                }
            }
            
            // Favorite star button
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundColor(isFavorite ? .orange : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20, height: 20)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(priceChangeColor.opacity(0.15))
        )
    }
    
    // Computed property for properly formatted price with currency conversion
    private var formattedPrice: String {
        return cryptocurrency.formattedPrice(in: settingsManager.currencyPreference)
    }
    
    // Computed property for properly formatted percentage change
    private var formattedPercentageChange: String {
        guard let change = cryptocurrency.priceChangePercentage24h else { return "0.00%" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))%"
    }
    
    // Computed property for price change color that works well in both light and dark modes
    private var priceChangeColor: Color {
        let change = cryptocurrency.priceChangePercentage24h ?? 0
        if change >= 0 {
            return Color.green
        } else {
            return Color.red
        }
    }
}

#Preview {
    CryptocurrencyRowView(
        cryptocurrency: Cryptocurrency(
            id: "90",
            nameid: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            image: "",
            currentPrice: 450000.0,
            marketCap: 850000000000,
            marketCapRank: 1000,
            priceChangePercentage24h: 2.5
        ),
        isFavorite: false,
        onFavoriteToggle: {}
    )
    .environmentObject(SettingsManager.shared)
} 
