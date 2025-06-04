//
//  HeaderView.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    @Binding var showingSearch: Bool
    @Binding var showingSettings: Bool
    
    var body: some View {
        HStack {
            // Search icon button
            Button(action: {
                showingSearch.toggle()
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 24, height: 24)
            .accessibilityIdentifier(AppConstants.Accessibility.searchFieldIdentifier)
            
            Spacer()
            
            // Page title
            Text(title)
                .font(.system(size: 12))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            // Settings icon button
            Button(action: {
                showingSettings.toggle()
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 24, height: 24)
            .accessibilityIdentifier(AppConstants.Accessibility.settingsButtonIdentifier)
        }
        .padding(.horizontal, 12)
        .frame(height: 32)
    }
}

#Preview {
    HeaderView(
        title: "Crypto Watch",
        showingSearch: .constant(false),
        showingSettings: .constant(false)
    )
} 