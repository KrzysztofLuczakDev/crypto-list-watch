//
//  SettingsDetailViews.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

// MARK: - Currency Selection View
struct CurrencySelectionView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private var majorGlobalCurrencies: [CurrencyPreference] {
        [.usd, .eur, .gbp, .jpy, .cad, .aud, .chf, .cny]
    }
    
    private var europeanCurrencies: [CurrencyPreference] {
        CurrencyPreference.allCases.filter { $0.isEuropean && !majorGlobalCurrencies.contains($0) }
    }
    
    private var cryptoCurrencies: [CurrencyPreference] {
        CurrencyPreference.allCases.filter { $0.isCrypto }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Major Global Currencies Section
                VStack(spacing: 8) {
                    HStack {
                        Text("Major Global")
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    ForEach(majorGlobalCurrencies, id: \.self) { currency in
                        currencyRow(currency)
                    }
                }
                
                // European Currencies Section
                if !europeanCurrencies.isEmpty {
                    VStack(spacing: 8) {
                        HStack {
                            Text("European")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        ForEach(europeanCurrencies, id: \.self) { currency in
                            currencyRow(currency)
                        }
                    }
                }
                
                // Cryptocurrencies Section
                VStack(spacing: 8) {
                    HStack {
                        Text("Cryptocurrencies")
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    ForEach(cryptoCurrencies, id: \.self) { currency in
                        currencyRow(currency)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func currencyRow(_ currency: CurrencyPreference) -> some View {
        Button(action: {
            settingsManager.currencyPreference = currency
            dismiss()
        }) {
            HStack {
                Text(currency.symbol)
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                    .frame(width: 24, alignment: .leading)
                
                Text(currency.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if settingsManager.currencyPreference == currency {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Refresh Interval Selection View
struct RefreshIntervalSelectionView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(DataRefreshInterval.allCases, id: \.self) { interval in
                    Button(action: {
                        settingsManager.dataRefreshInterval = interval
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: interval == .manual ? "hand.raised" : "arrow.clockwise")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                                .frame(width: 16)
                            
                            Text(interval.displayName)
                                .font(.system(size: 10))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if settingsManager.dataRefreshInterval == interval {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.primary.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle("Refresh Interval")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Watchlist Sorting Selection View
struct WatchlistSortingSelectionView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(WatchlistSortingPreference.allCases, id: \.self) { sorting in
                    Button(action: {
                        settingsManager.watchlistSorting = sorting
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: sorting.iconName)
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                                .frame(width: 16)
                            
                            Text(sorting.displayName)
                                .font(.system(size: 10))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if settingsManager.watchlistSorting == sorting {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.primary.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle("Sorting")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Chart Time Range Selection View
struct ChartTimeRangeSelectionView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(DefaultChartTimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        settingsManager.defaultChartTimeRange = range
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                                .frame(width: 16)
                            
                            Text(range.displayName)
                                .font(.system(size: 10))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if settingsManager.defaultChartTimeRange == range {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.primary.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle("Chart Range")
        .navigationBarTitleDisplayMode(.inline)
    }
} 