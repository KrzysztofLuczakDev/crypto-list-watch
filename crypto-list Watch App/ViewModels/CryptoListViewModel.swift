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
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var selectedTab = 0 // 0 for top coins, 1 for favorites
    
    private let coinLoreService = CoinLoreService.shared
    private let favoritesManager = FavoritesManager.shared
    private let settingsManager = SettingsManager.shared
    private var searchTask: Task<Void, Never>?
    private var refreshTimer: Timer?
    
    // Track when data was last loaded to avoid unnecessary refreshes
    private var topCoinsLastLoaded: Date?
    private var favoritesLastLoaded: Date?
    private let dataValidityDuration: TimeInterval = 30 // Data is considered fresh for 30 seconds
    
    // Pagination properties
    private let itemsPerPage = 50 // Reasonable page size for watch
    private var currentPage = 0
    private var totalCoinsAvailable = 0
    private var hasMoreData = true
    
    var canLoadMore: Bool {
        return hasMoreData && !isLoading && !isLoadingMore
    }
    
    init() {
        loadTopCryptocurrencies()
        loadFavorites()
        setupAutoRefresh()
        
        // Listen for settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: .settingsDidChange,
            object: nil
        )
    }
    
    deinit {
        refreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func settingsDidChange() {
        setupAutoRefresh()
        // Force reload favorites to apply new sorting changes
        loadFavorites()
        // Also force reload top cryptocurrencies if we're on that tab
        if selectedTab == 0 {
            loadTopCryptocurrencies()
        }
    }
    
    private func setupAutoRefresh() {
        refreshTimer?.invalidate()
        
        guard settingsManager.shouldAutoRefresh(),
              let interval = settingsManager.getCurrentRefreshInterval() else {
            return
        }
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                // Use smart refresh for auto-refresh to avoid unnecessary API calls
                self?.refreshIfNeeded()
            }
        }
    }
    
    func loadTopCryptocurrencies() {
        isLoading = true
        errorMessage = nil
        currentPage = 0
        hasMoreData = true
        
        Task {
            do {
                let cryptos = try await coinLoreService.fetchTopCryptocurrencies(start: 0, limit: itemsPerPage)
                let totalCount = try await coinLoreService.getTotalCoinsCount()
                
                await MainActor.run {
                    self.cryptocurrencies = cryptos
                    self.totalCoinsAvailable = totalCount
                    self.hasMoreData = cryptos.count == self.itemsPerPage && (self.currentPage + 1) * self.itemsPerPage < totalCount
                    self.isLoading = false
                    self.topCoinsLastLoaded = Date()
                }
            } catch let error as CoinLoreError {
                await MainActor.run {
                    self.handleError(error)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadMoreCryptocurrencies() {
        guard canLoadMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        let startIndex = currentPage * itemsPerPage
        
        Task {
            do {
                let newCryptos = try await coinLoreService.fetchTopCryptocurrencies(start: startIndex, limit: itemsPerPage)
                
                await MainActor.run {
                    self.cryptocurrencies.append(contentsOf: newCryptos)
                    self.hasMoreData = newCryptos.count == self.itemsPerPage && (self.currentPage + 1) * self.itemsPerPage < self.totalCoinsAvailable
                    self.isLoadingMore = false
                }
            } catch let error as CoinLoreError {
                await MainActor.run {
                    // Revert page increment on error
                    self.currentPage -= 1
                    self.isLoadingMore = false
                    
                    // Only show error for critical issues
                    if case .noInternetConnection = error {
                        self.errorMessage = error.localizedDescription
                    }
                }
            } catch {
                await MainActor.run {
                    // Revert page increment on error
                    self.currentPage -= 1
                    self.isLoadingMore = false
                }
            }
        }
    }
    
    func loadFavorites() {
        let favoriteNameids = favoritesManager.getFavoriteNameidsList()
        print("CryptoListViewModel: Loading favorites with nameids: \(favoriteNameids)")
        
        guard !favoriteNameids.isEmpty else {
            print("CryptoListViewModel: No favorites to load")
            favoriteCryptocurrencies = []
            return
        }
        
        isFavoritesLoading = true
        
        Task {
            do {
                print("CryptoListViewModel: Fetching cryptocurrencies for nameids: \(favoriteNameids)")
                let cryptos = try await coinLoreService.fetchCryptocurrenciesByNameids(nameids: favoriteNameids)
                print("CryptoListViewModel: Successfully fetched \(cryptos.count) favorite cryptocurrencies")
                
                await MainActor.run {
                    self.favoriteCryptocurrencies = self.sortFavorites(cryptos)
                    self.isFavoritesLoading = false
                    print("CryptoListViewModel: Updated favorites list with \(self.favoriteCryptocurrencies.count) items")
                    self.favoritesLastLoaded = Date()
                }
            } catch let error as CoinLoreError {
                print("CryptoListViewModel: CoinLore error loading favorites: \(error)")
                await MainActor.run {
                    self.isFavoritesLoading = false
                    // Only show error for critical issues
                    if case .noInternetConnection = error {
                        self.errorMessage = error.localizedDescription
                    }
                }
            } catch {
                print("CryptoListViewModel: Unexpected error loading favorites: \(error)")
                await MainActor.run {
                    self.isFavoritesLoading = false
                    // Don't show error for favorites, just keep empty list
                }
            }
        }
    }
    
    private func sortFavorites(_ cryptos: [Cryptocurrency]) -> [Cryptocurrency] {
        switch settingsManager.watchlistSorting {
        case .marketCap:
            return cryptos.sorted { ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
        case .volume:
            return cryptos.sorted { ($0.totalVolume ?? 0) > ($1.totalVolume ?? 0) }
        case .price:
            return cryptos.sorted { $0.currentPrice > $1.currentPrice }
        case .alphabetical:
            return cryptos.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .priceChange:
            return cryptos.sorted { ($0.priceChangePercentage24h ?? 0) > ($1.priceChangePercentage24h ?? 0) }
        }
    }
    
    func toggleFavorite(_ cryptocurrency: Cryptocurrency) {
        favoritesManager.toggleFavorite(cryptocurrency)
        // Invalidate favorites cache since the list changed
        favoritesLastLoaded = nil
        // Smart refresh will detect the change and reload if needed
        if selectedTab == 1 {
            loadFavoritesIfNeeded()
        }
    }
    
    func isFavorite(_ cryptocurrency: Cryptocurrency) -> Bool {
        return favoritesManager.isFavorite(cryptocurrency)
    }
    
    func searchCryptocurrencies() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= 2 else { // Minimum search length
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
                let results = try await coinLoreService.searchCryptocurrencies(query: trimmedQuery)
                await MainActor.run {
                    if !Task.isCancelled {
                        self.searchResults = results
                        self.isSearching = false
                    }
                }
            } catch let error as CoinLoreError {
                await MainActor.run {
                    if !Task.isCancelled {
                        // Show rate limit errors to user
                        if case .rateLimitExceeded = error {
                            self.errorMessage = error.localizedDescription
                        }
                        self.searchResults = []
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
    
    /// Smart refresh that only loads data if it's stale or missing
    func refreshIfNeeded() {
        if selectedTab == 0 {
            loadTopCryptocurrenciesIfNeeded()
        } else {
            loadFavoritesIfNeeded()
        }
    }
    
    /// Force refresh regardless of data freshness (for pull-to-refresh, settings changes, etc.)
    func forceRefresh() {
        refresh()
    }
    
    /// Load top cryptocurrencies only if data is stale or missing
    private func loadTopCryptocurrenciesIfNeeded() {
        // Check if we have fresh data
        if let lastLoaded = topCoinsLastLoaded,
           Date().timeIntervalSince(lastLoaded) < dataValidityDuration,
           !cryptocurrencies.isEmpty {
            print("CryptoListViewModel: Top coins data is still fresh, skipping refresh")
            return
        }
        
        print("CryptoListViewModel: Top coins data is stale or missing, refreshing")
        loadTopCryptocurrencies()
    }
    
    /// Load favorites only if data is stale or missing
    private func loadFavoritesIfNeeded() {
        // Always check if favorites list has changed
        let currentFavoriteNameids = Set(favoritesManager.getFavoriteNameidsList())
        let loadedFavoriteNameids = Set(favoriteCryptocurrencies.map { $0.nameid })
        
        // If favorites list changed, we need to reload
        if currentFavoriteNameids != loadedFavoriteNameids {
            print("CryptoListViewModel: Favorites list changed, refreshing")
            loadFavorites()
            return
        }
        
        // Check if we have fresh data
        if let lastLoaded = favoritesLastLoaded,
           Date().timeIntervalSince(lastLoaded) < dataValidityDuration,
           !favoriteCryptocurrencies.isEmpty {
            print("CryptoListViewModel: Favorites data is still fresh, skipping refresh")
            return
        }
        
        print("CryptoListViewModel: Favorites data is stale or missing, refreshing")
        loadFavorites()
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: CoinLoreError) {
        switch error {
        case .noInternetConnection:
            self.errorMessage = "No internet connection. Please check your network and try again."
        case .rateLimitExceeded:
            self.errorMessage = "Too many requests. Please wait a moment before trying again."
        case .serverError:
            self.errorMessage = "Server is temporarily unavailable. Please try again later."
        case .invalidResponse:
            self.errorMessage = "Invalid response from server. Please try again."
        case .networkError(let error):
            self.errorMessage = "Network error: \(error.localizedDescription)"
        }
    }
    
    /// Re-sorts the current favorites list without reloading from API
    func applySortingToFavorites() {
        favoriteCryptocurrencies = sortFavorites(favoriteCryptocurrencies)
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
} 