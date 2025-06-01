//
//  CryptoListViewModel.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation
import SwiftUI

@MainActor
class CryptoListViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var favoriteCryptocurrencies: [Cryptocurrency] = []
    @Published var searchResults: [Cryptocurrency] = []
    @Published var isLoading = false
    @Published var isFavoritesLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var selectedTab = 0 // 0 for top coins, 1 for favorites
    
    private let coinGeckoService = CoinGeckoService.shared
    private let favoritesManager = FavoritesManager.shared
    private var searchTask: Task<Void, Never>?
    
    init() {
        loadTopCryptocurrencies()
        loadFavorites()
    }
    
    func loadTopCryptocurrencies() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let cryptos = try await coinGeckoService.fetchTopCryptocurrencies(limit: 10)
                await MainActor.run {
                    self.cryptocurrencies = cryptos
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadFavorites() {
        let favoriteIds = favoritesManager.getFavoritesList()
        guard !favoriteIds.isEmpty else {
            favoriteCryptocurrencies = []
            return
        }
        
        isFavoritesLoading = true
        
        Task {
            do {
                let cryptos = try await coinGeckoService.fetchCryptocurrenciesByIds(favoriteIds)
                await MainActor.run {
                    self.favoriteCryptocurrencies = cryptos
                    self.isFavoritesLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isFavoritesLoading = false
                    // Don't show error for favorites, just keep empty list
                }
            }
        }
    }
    
    func toggleFavorite(_ cryptocurrency: Cryptocurrency) {
        favoritesManager.toggleFavorite(cryptocurrency.id)
        loadFavorites() // Reload favorites to update the list
    }
    
    func isFavorite(_ cryptocurrency: Cryptocurrency) -> Bool {
        return favoritesManager.isFavorite(cryptocurrency.id)
    }
    
    func searchCryptocurrencies() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }
        
        // Cancel previous search task
        searchTask?.cancel()
        
        isSearching = true
        
        searchTask = Task {
            // Add a small delay to avoid too many API calls
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            guard !Task.isCancelled else { return }
            
            do {
                let results = try await coinGeckoService.searchCryptocurrencies(query: trimmedQuery)
                await MainActor.run {
                    if !Task.isCancelled {
                        self.searchResults = results
                        self.isSearching = false
                    }
                }
            } catch {
                await MainActor.run {
                    if !Task.isCancelled {
                        // Don't show error for search, just clear results
                        self.searchResults = []
                        self.isSearching = false
                    }
                }
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        isSearching = false
        searchTask?.cancel()
    }
    
    func refresh() {
        if selectedTab == 0 {
            loadTopCryptocurrencies()
        } else {
            loadFavorites()
        }
    }
} 