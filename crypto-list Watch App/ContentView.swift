//
//  ContentView.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CryptoListViewModel()
    @State private var showingSearch = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Tab View
                TabView(selection: $viewModel.selectedTab) {
                    // Top Coins Tab
                    topCoinsView
                        .tag(0)
                    
                    // Favorites Tab
                    favoritesView
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
        }
    }
    
    private var topCoinsView: some View {
        VStack {
            // Tab title
            HStack {
                Text("Top Coins")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            // Content
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else {
                cryptoList(cryptocurrencies: viewModel.searchText.isEmpty ? viewModel.cryptocurrencies : viewModel.searchResults)
            }
        }
    }
    
    private var favoritesView: some View {
        VStack {
            // Tab title
            HStack {
                Text("Favorites")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            // Content
            if viewModel.isFavoritesLoading {
                loadingView
            } else if viewModel.favoriteCryptocurrencies.isEmpty {
                emptyFavoritesView
            } else {
                cryptoList(cryptocurrencies: viewModel.favoriteCryptocurrencies)
            }
        }
    }

private var searchBar: some View {
    HStack(spacing: 6) {
        Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
            .font(.system(size: 10))

        TextField("Search...", text: $viewModel.searchText)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.system(size: 11))
            .disableAutocorrection(true)
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.searchCryptocurrencies()
            }

        if !viewModel.searchText.isEmpty {
            Button(action: viewModel.clearSearch) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    .padding(.horizontal, 8)
    .frame(height: 26)
    .background(Color(white: 0.15).opacity(0.2))
    .clipShape(Capsule())
    .padding(.horizontal, 12)
    .padding(.top, 2)
}

    
    private func cryptoList(cryptocurrencies: [Cryptocurrency]) -> some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                if cryptocurrencies.isEmpty && !viewModel.searchText.isEmpty {
                    emptySearchView
                } else {
                    ForEach(cryptocurrencies) { crypto in
                        CryptocurrencyRowView(
                            cryptocurrency: crypto,
                            isFavorite: viewModel.isFavorite(crypto),
                            onFavoriteToggle: {
                                viewModel.toggleFavorite(crypto)
                            }
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 4)
        }
        .refreshable {
            viewModel.refresh()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                viewModel.refresh()
            }
            .font(.caption)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text("Try a different search term")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 8) {
            Image(systemName: "star")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No Favorites")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text("Tap the star next to any coin to add it to your favorites")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
