//
//  SettingsView.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsManager: SettingsManager
    
    // Navigation states
    @State private var showingCurrencySelection = false
    @State private var showingRefreshIntervalSelection = false
    @State private var showingSortingSelection = false
    @State private var showingFAQ = false
    @State private var showingReportBug = false
    @State private var showingTermsPrivacy = false
    @State private var showingAPIUsage = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Preferences Section
                    preferencesSection
                    
                    // Watchlist Settings Section
                    watchlistSettingsSection
                    
                    // Developer Section
                    developerSection
                    
                    // Help & Support Section
                    helpSupportSection

                    // About Section
                    aboutSection
                    
                    // App Info Section
                    appInfoSection
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primary.opacity(0.02))
        }
        // Navigation sheets
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView()
                .environmentObject(settingsManager)
        }
        .sheet(isPresented: $showingRefreshIntervalSelection) {
            RefreshIntervalSelectionView()
                .environmentObject(settingsManager)
        }
        .sheet(isPresented: $showingSortingSelection) {
            FavoritesSortingSelectionView()
                .environmentObject(settingsManager)
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
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Crypto Watch")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("v1.0.0")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(spacing: 8) {
            SettingsSectionHeader(title: "Preferences", icon: "gear")
            
            VStack(spacing: 6) {
                SettingsNavigationRow(
                    icon: "dollarsign.circle",
                    title: "Currency",
                    value: settingsManager.currencyPreference.displayName
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
            SettingsSectionHeader(title: "Favorites Settings", icon: "star")
            
            VStack(spacing: 6) {
                SettingsNavigationRow(
                    icon: settingsManager.watchlistSorting.iconName,
                    title: "Sorting",
                    value: settingsManager.watchlistSorting.displayName
                ) {
                    showingSortingSelection = true
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
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                Text("About")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Text("Real-time cryptocurrency prices for Apple Watch")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            // Reset Settings Button
            Button(action: {
                settingsManager.resetToDefaults()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.red)
                    
                    Text("Reset to Defaults")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.2), lineWidth: 0.5)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
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
        .environmentObject(SettingsManager.shared)
} 