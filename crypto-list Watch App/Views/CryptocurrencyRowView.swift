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
    
    var body: some View {
        HStack(spacing: 8) {
            // Rank badge
            Text("#\(cryptocurrency.marketCapRank)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 25, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                // Name and Symbol
                HStack {
                    Text(cryptocurrency.symbol.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(cryptocurrency.formattedPrice)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Name and 24h change
                HStack {
                    Text(cryptocurrency.name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(cryptocurrency.formattedPriceChange)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(cryptocurrency.priceChangePercentage24h ?? 0 >= 0 ? .green : .red)
                }
            }
            
            // Favorite star button
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 15))
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
            image: "",
            currentPrice: 45000.0,
            marketCap: 850000000000,
            marketCapRank: 1,
            priceChangePercentage24h: 2.5
        ),
        isFavorite: false,
        onFavoriteToggle: {}
    )
} 