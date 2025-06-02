//
//  SettingsView.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settingsManager = SettingsManager.shared
    
    // Navigation states
    @State private var showingCurrencySelection = false
    @State private var showingRefreshIntervalSelection = false
    @State private var showingSortingSelection = false
    @State private var showingChartRangeSelection = false
    @State private var showingFAQ = false
    @State private var showingReportBug = false
    @State private var showingTermsPrivacy = false
    @State private var showingAPIUsage = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // App Info Section
                    appInfoSection
                    
                    Divider()
                    
                    // Preferences Section
                    preferencesSection
                    
                    Divider()
                    
                    // Watchlist Settings Section
                    watchlistSettingsSection
                    
                    Divider()
                    
                    // Developer Section
                    developerSection
                    
                    Divider()
                    
                    // Help & Support Section
                    helpSupportSection
                    
                    Divider()
                    
                    // About Section
                    aboutSection
                }
                .padding(.horizontal, 12)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Navigation sheets
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView()
        }
        .sheet(isPresented: $showingRefreshIntervalSelection) {
            RefreshIntervalSelectionView()
        }
        .sheet(isPresented: $showingSortingSelection) {
            WatchlistSortingSelectionView()
        }
        .sheet(isPresented: $showingChartRangeSelection) {
            ChartTimeRangeSelectionView()
        }
        .sheet(isPresented: $showingFAQ) {
            FAQView()
        }
        .sheet(isPresented: $showingReportBug) {
            ReportBugView()
        }
        .sheet(isPresented: $showingTermsPrivacy) {
            TermsPrivacyView()
        }
        .sheet(isPresented: $showingAPIUsage) {
            APIUsageDebugView()
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("Crypto List")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("v1.0.0")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(spacing: 8) {
            SettingsSectionHeader(title: "Preferences", icon: "gear")
            
            VStack(spacing: 6) {
                SettingsNavigationRow(
                    icon: "dollarsign.circle",
                    title: "Currency",
                    value: "\(settingsManager.currencyPreference.symbol) \(settingsManager.currencyPreference.displayName)"
                ) {
                    showingCurrencySelection = true
                }
                
                SettingsNavigationRow(
                    icon: "arrow.clockwise",
                    title: "Refresh Interval",
                    value: settingsManager.dataRefreshInterval.displayName
                ) {
                    showingRefreshIntervalSelection = true
                }
            }
        }
    }
    
    // MARK: - Watchlist Settings Section
    private var watchlistSettingsSection: some View {
        VStack(spacing: 8) {
            SettingsSectionHeader(title: "Watchlist Settings", icon: "star")
            
            VStack(spacing: 6) {
                SettingsNavigationRow(
                    icon: settingsManager.watchlistSorting.iconName,
                    title: "Sorting",
                    value: settingsManager.watchlistSorting.displayName
                ) {
                    showingSortingSelection = true
                }
                
                SettingsNavigationRow(
                    icon: "chart.xyaxis.line",
                    title: "Default Chart Range",
                    value: settingsManager.defaultChartTimeRange.displayName
                ) {
                    showingChartRangeSelection = true
                }
            }
        }
    }
    
    // MARK: - Developer Section
    private var developerSection: some View {
        VStack(spacing: 8) {
            SettingsSectionHeader(title: "Developer", icon: "hammer")
            
            VStack(spacing: 6) {
                SettingsActionRow(
                    icon: "chart.bar",
                    title: "API Usage"
                ) {
                    showingAPIUsage = true
                }
            }
        }
    }
    
    // MARK: - Help & Support Section
    private var helpSupportSection: some View {
        VStack(spacing: 8) {
            SettingsSectionHeader(title: "Help & Support", icon: "questionmark.circle")
            
            VStack(spacing: 6) {
                SettingsActionRow(
                    icon: "questionmark.circle",
                    title: "FAQ"
                ) {
                    showingFAQ = true
                }
                
                SettingsActionRow(
                    icon: "ladybug",
                    title: "Report a Bug"
                ) {
                    showingReportBug = true
                }
                
                SettingsActionRow(
                    icon: "doc.text",
                    title: "Terms & Privacy"
                ) {
                    showingTermsPrivacy = true
                }
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 6) {
            Text("About")
                .font(.system(size: 11))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Real-time cryptocurrency prices powered by CoinLore API with completely free currency conversion (no limits)")
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            // Reset Settings Button
            Button(action: {
                settingsManager.resetToDefaults()
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                    
                    Text("Reset to Defaults")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primary.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
        }
    }
}

// Keep the original SettingsRow for backward compatibility if needed elsewhere
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .frame(width: 16)
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(white: 0.15).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    SettingsView()
} 