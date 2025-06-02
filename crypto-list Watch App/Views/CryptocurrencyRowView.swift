//
//  CryptocurrencyRowView.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct CryptocurrencyRowView: View {
    let cryptocurrency: Cryptocurrency
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    @ObservedObject private var settingsManager = SettingsManager.shared
    
    // Computed property for dynamic rank font size
    private var rankFontSize: CGFloat {
        let rankString = String(cryptocurrency.marketCapRank)
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
            Text("#\(cryptocurrency.marketCapRank)")
                .font(.system(size: rankFontSize))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                // Name and Symbol with icon
                HStack {
                    // Coin icon
                    AsyncImage(url: URL(string: cryptocurrency.image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                    }
                    .frame(width: 12, height: 12)
                    
                    Text("\(cryptocurrency.symbol.uppercased())/\(settingsManager.currencyPreference.displayName)")
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(cryptocurrency.priceChangePercentage24h.formatAsPercentage())
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(priceChangeColor)
                }
                
                // Price with proper currency formatting and color coding
                HStack {
                    Text(cryptocurrency.currentPrice.formatAsCurrency(currency: settingsManager.currencyPreference))
                        .font(.system(size: 11))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
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
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.05))
        )
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
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            currentPrice: 450000.0,
            marketCap: 850000000000,
            marketCapRank: 1000,
            priceChangePercentage24h: 2.5
        ),
        isFavorite: false,
        onFavoriteToggle: {}
    )
}
