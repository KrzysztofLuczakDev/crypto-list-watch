//
//  CryptoWidgetViews.swift
//  Crypto Watch Widget Extension
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import WidgetKit
import SwiftUI

struct CryptoWidgetEntryView: View {
    var entry: CryptoEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryCorner:
            CornerWidgetView(entry: entry)
        default:
            RectangularWidgetView(entry: entry)
        }
    }
}

// MARK: - Rectangular Widget View
struct RectangularWidgetView: View {
    let entry: CryptoEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text("Crypto")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            ForEach(Array(entry.cryptocurrencies.prefix(2).enumerated()), id: \.offset) { index, crypto in
                HStack {
                    Text(crypto.symbol.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(crypto.formattedPrice)
                            .font(.caption2)
                            .fontWeight(.semibold)
                        
                        Text(crypto.formattedPriceChange)
                            .font(.system(size: 9))
                            .foregroundColor(crypto.isPositiveChange ? .green : .red)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

// MARK: - Circular Widget View
struct CircularWidgetView: View {
    let entry: CryptoEntry
    
    var body: some View {
        if let firstCrypto = entry.cryptocurrencies.first {
            VStack(spacing: 1) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text(firstCrypto.symbol.uppercased())
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                
                Text(formatPriceForCircular(firstCrypto.currentPrice))
                    .font(.system(size: 8))
                    .fontWeight(.semibold)
                
                Text(firstCrypto.formattedPriceChange)
                    .font(.system(size: 7))
                    .foregroundColor(firstCrypto.isPositiveChange ? .green : .red)
            }
        } else {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.title3)
                .foregroundColor(.orange)
        }
    }
    
    private func formatPriceForCircular(_ price: Double) -> String {
        if price >= 1000 {
            return "$\(String(format: "%.0fK", price / 1000))"
        } else if price >= 1 {
            return "$\(String(format: "%.0f", price))"
        } else {
            return "$\(String(format: "%.2f", price))"
        }
    }
}

// MARK: - Corner Widget View
struct CornerWidgetView: View {
    let entry: CryptoEntry
    
    var body: some View {
        if let firstCrypto = entry.cryptocurrencies.first {
            VStack(alignment: .leading, spacing: 1) {
                Text(firstCrypto.symbol.uppercased())
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                
                Text(formatPriceForCorner(firstCrypto.currentPrice))
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                
                HStack(spacing: 2) {
                    Image(systemName: firstCrypto.isPositiveChange ? "arrow.up" : "arrow.down")
                        .font(.system(size: 6))
                        .foregroundColor(firstCrypto.isPositiveChange ? .green : .red)
                    
                    Text(firstCrypto.formattedPriceChange)
                        .font(.system(size: 8))
                        .foregroundColor(firstCrypto.isPositiveChange ? .green : .red)
                }
            }
        } else {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.title3)
                .foregroundColor(.orange)
        }
    }
    
    private func formatPriceForCorner(_ price: Double) -> String {
        if price >= 1000 {
            return "$\(String(format: "%.0fK", price / 1000))"
        } else if price >= 1 {
            return "$\(String(format: "%.0f", price))"
        } else {
            return "$\(String(format: "%.3f", price))"
        }
    }
}

// MARK: - Previews
#Preview("Rectangular", as: .accessoryRectangular) {
    CryptoWidget()
} timeline: {
    CryptoEntry(date: .now, cryptocurrencies: sampleCryptos)
}

#Preview("Circular", as: .accessoryCircular) {
    CryptoWidget()
} timeline: {
    CryptoEntry(date: .now, cryptocurrencies: sampleCryptos)
}

#Preview("Corner", as: .accessoryCorner) {
    CryptoWidget()
} timeline: {
    CryptoEntry(date: .now, cryptocurrencies: sampleCryptos)
} 