//
//  CryptocurrencyRowView.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

extension Double {
    var formattedCryptoPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US") // Use period as decimal separator
        
        // Determine appropriate decimal places based on price magnitude
        if self >= 1000 {
            // Large prices: show 2 decimal places with thousand separators
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.usesGroupingSeparator = true
        } else if self >= 1 {
            // Moderate prices: show up to 4 decimal places
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 4
            formatter.usesGroupingSeparator = false
        } else if self >= 0.01 {
            // Small prices: show up to 6 decimal places
            formatter.minimumFractionDigits = 4
            formatter.maximumFractionDigits = 6
            formatter.usesGroupingSeparator = false
        } else {
            // Very small prices: show up to 8 decimal places (like Bitcoin's satoshi precision)
            formatter.minimumFractionDigits = 6
            formatter.maximumFractionDigits = 8
            formatter.usesGroupingSeparator = false
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? String(format: "%.8f", self)
    }
}

struct CryptocurrencyRowView: View {
    let cryptocurrency: Cryptocurrency
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
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
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 12, height: 12)
                    
                    Text("\(cryptocurrency.symbol.uppercased())/USDT")
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(cryptocurrency.formattedPriceChange)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(cryptocurrency.priceChangePercentage24h ?? 0 >= 0 ? .green : .red)
                }
                
                // Price with proper crypto formatting and color coding
                HStack {
                    Text(cryptocurrency.currentPrice.formattedCryptoPrice)
                        .font(.system(size: 11))
                        .fontWeight(.semibold)
                        .foregroundColor(
                            (cryptocurrency.priceChangePercentage24h ?? 0) >= 0 ? .green : .red
                        )
                }
            }
            
            // Favorite star button
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundColor(isFavorite ? .yellow : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20, height: 20)
        }
        .padding(.vertical, 2)
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
