//
//  SettingsView.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // App Info Section
                    VStack(spacing: 8) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Text("Crypto List")
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                        
                        Text("v1.0.0")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    Divider()
                    
                    // Settings Options
                    VStack(spacing: 8) {
                        SettingsRow(
                            icon: "arrow.clockwise",
                            title: "Refresh Rate",
                            value: "30s"
                        )
                        
                        SettingsRow(
                            icon: "bell",
                            title: "Notifications",
                            value: "Off"
                        )
                        
                        SettingsRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Currency",
                            value: "USD"
                        )
                    }
                    
                    Divider()
                    
                    // About Section
                    VStack(spacing: 6) {
                        Text("About")
                            .font(.system(size: 11))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Real-time cryptocurrency prices powered by CoinGecko API")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 12)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 11))
                }
            }
        }
    }
}

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