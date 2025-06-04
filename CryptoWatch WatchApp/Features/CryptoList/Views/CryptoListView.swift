//
//  CryptoListView.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct CryptoListView: View {
    @StateObject private var model = CryptoListModel()
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @EnvironmentObject private var currencyService: CurrencyConversionService
    
    @State private var showingSearch = false
    @State private var showingSettings = false
    
    // Computed property for dynamic title
    private var currentTitle: String {
        switch model.selectedTab {
        case 0:
            return "Top Coins"
        case 1:
            return "Favorites"
        default:
            return "Crypto Watch"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with dynamic title
                HeaderView(
                    title: currentTitle,
                    showingSearch: $showingSearch,
                    showingSettings: $showingSettings
                )
                
                // Search Bar (shown conditionally)
                if showingSearch {
                    searchBar
                }
                
                // Tab View
                TabView(selection: $model.selectedTab) {
                    // Top Coins Tab
                    topCoinsView
                        .tag(0)
                    
                    // Favorites Tab
                    favoritesView
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .onChange(of: model.selectedTab) { oldValue, newValue in
                    // Only refresh if data is stale when switching tabs
                    model.refreshIfNeeded()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settingsManager)
        }
    }
    
    private var topCoinsView: some View {
        VStack {
            // Content
            if model.isLoading {
                loadingView
            } else if let errorMessage = model.errorMessage {
                errorView(errorMessage)
            } else {
                cryptoList(cryptocurrencies: model.searchText.isEmpty ? model.cryptocurrencies : model.searchResults)
            }
        }
    }
    
    private var favoritesView: some View {
        VStack {
            // Content
            if model.isFavoritesLoading {
                loadingView
            } else if model.favoriteCryptocurrencies.isEmpty {
                emptyFavoritesView
            } else {
                cryptoList(cryptocurrencies: model.favoriteCryptocurrencies)
            }
        }
    }
    private var searchBar: some View {
        HStack(spacing: 6) {
            TextField("Search...", text: $model.searchText)
                .font(.system(size: 9))
                .disableAutocorrection(true)
                .frame(height: 20)
                .onChange(of: model.searchText) {
                    model.searchCryptocurrencies()
                }
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)

            if !model.searchText.isEmpty {
                Button(action: model.clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Close search button
            Button(action: {
                showingSearch = false
                model.clearSearch()
            }) {
                Text("Close")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 6)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: showingSearch)
    }

    
    private func cryptoList(cryptocurrencies: [Cryptocurrency]) -> some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                if cryptocurrencies.isEmpty && !model.searchText.isEmpty {
                    emptySearchView
                } else {
                    ForEach(Array(cryptocurrencies.enumerated()), id: \.element.id) { index, crypto in
                        CryptocurrencyRowView(
                            cryptocurrency: crypto,
                            isFavorite: model.isFavorite(crypto),
                            onFavoriteToggle: {
                                model.toggleFavorite(crypto)
                            }
                        )
                        .onAppear {
                            // Load more data when approaching the end (for top coins tab only)
                            if shouldLoadMore(currentIndex: index, totalCount: cryptocurrencies.count) {
                                model.loadMoreCryptocurrencies()
                            }
                        }
                    }
                    
                    // Loading indicator for pagination
                    if model.isLoadingMore {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading more...")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.top, 4)
        }
        .refreshable {
            model.forceRefresh()
        }
    }
    
    private func shouldLoadMore(currentIndex: Int, totalCount: Int) -> Bool {
        // Only load more for top coins tab, not for search results or favorites
        guard model.selectedTab == 0 && model.searchText.isEmpty else {
            return false
        }
        
        // Load more when we're near the end (within 10 items) and can load more
        return currentIndex >= totalCount - 10 && model.canLoadMore
    }
    
    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(1.0)
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
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                model.refresh()
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No Favorites")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Tap the heart icon on any cryptocurrency to add it to your favorites.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Try searching with a different term.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
#Preview {
    CryptoListView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(FavoritesManager.shared)
        .environmentObject(CurrencyConversionService.shared)
} 
