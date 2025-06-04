//
//  SettingsComponents.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

// MARK: - Settings Section Header

struct SettingsSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.orange)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                )
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Settings Navigation Row

struct SettingsNavigationRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 18, height: 18)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(value)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Action Row

struct SettingsActionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 18, height: 18)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.orange)
                .frame(width: 18, height: 18)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Currency Section Header

struct CurrencySectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.orange)
                .frame(width: 16, height: 16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.orange.opacity(0.08))
        )
    }
}

// MARK: - Currency Row

struct CurrencyRow: View {
    let currency: CurrencyPreference
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Currency name only (no symbol icon)
                Text(currency.displayName)
                    .font(.caption2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                } else {
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.orange.opacity(0.05) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.orange.opacity(0.2) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Selection Views

struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsManager: SettingsManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // FIAT Currencies Section
                    VStack(spacing: 6) {
                        CurrencySectionHeader(title: "Fiat", icon: "banknote")
                        
                        LazyVStack(spacing: 4) {
                            ForEach(CurrencyPreference.fiatCurrencies, id: \.self) { currency in
                                CurrencyRow(
                                    currency: currency,
                                    isSelected: settingsManager.currencyPreference == currency
                                ) {
                                    settingsManager.currencyPreference = currency
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    // Crypto Currencies Section
                    VStack(spacing: 6) {
                        CurrencySectionHeader(title: "Crypto", icon: "bitcoinsign.circle")
                        
                        LazyVStack(spacing: 4) {
                            ForEach(CurrencyPreference.cryptoCurrencies, id: \.self) { currency in
                                CurrencyRow(
                                    currency: currency,
                                    isSelected: settingsManager.currencyPreference == currency
                                ) {
                                    settingsManager.currencyPreference = currency
                                    dismiss()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
    }
}

struct RefreshIntervalSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsManager: SettingsManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(DataRefreshInterval.allCases, id: \.self) { interval in
                        Button(action: {
                            settingsManager.dataRefreshInterval = interval
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                // Icon based on interval type
                                Image(systemName: interval == .live ? "bolt.fill" : "arrow.clockwise")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.orange)
                                    .frame(width: 18, height: 18)
                                
                                Text(interval.displayName)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if settingsManager.dataRefreshInterval == interval {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                } else {
                                    Circle()
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(settingsManager.dataRefreshInterval == interval ? Color.orange.opacity(0.05) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(settingsManager.dataRefreshInterval == interval ? Color.orange.opacity(0.2) : Color.clear, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .navigationTitle("Refresh Interval")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
    }
}

struct FavoritesSortingSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsManager: SettingsManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(WatchlistSortingPreference.allCases, id: \.self) { sorting in
                        Button(action: {
                            settingsManager.watchlistSorting = sorting
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: sorting.iconName)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.orange)
                                    .frame(width: 18, height: 18)
                                
                                Text(sorting.displayName)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if settingsManager.watchlistSorting == sorting {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                } else {
                                    Circle()
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(settingsManager.watchlistSorting == sorting ? Color.orange.opacity(0.05) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(settingsManager.watchlistSorting == sorting ? Color.orange.opacity(0.2) : Color.clear, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .navigationTitle("Sorting")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
    }
}

// MARK: - Placeholder Views for Help & Support

struct FAQView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange.opacity(0.6))
                    
                    Text("FAQ")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Frequently asked questions and answers will be available here soon.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
            }
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
    }
}

struct ReportBugView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "ladybug")
                        .font(.system(size: 40))
                        .foregroundColor(.red.opacity(0.6))
                    
                    Text("Report a Bug")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Bug reporting feature will be available soon. Thank you for helping us improve the app!")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
            }
            .navigationTitle("Report Bug")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
    }
}

struct TermsPrivacyView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.orange.opacity(0.6))
                    
                    Text("Terms & Privacy")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Terms of service and privacy policy information will be available here soon.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
            }
            .navigationTitle("Terms & Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
    }
}

struct APIUsageDebugView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                        .foregroundColor(.green.opacity(0.6))
                    
                    Text("API Usage")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("API usage statistics and debugging information will be available here soon.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
            }
            .navigationTitle("API Usage")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
    }
} 