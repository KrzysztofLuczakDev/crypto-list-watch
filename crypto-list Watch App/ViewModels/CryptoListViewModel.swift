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
    
    private let coinGeckoService = CoinGeckoService.shared
    private let favoritesManager = FavoritesManager.shared
    private var searchTask: Task<Void, Never>?
    
    // Pagination properties
    private var currentPage = 1
    private let itemsPerPage = CoinGeckoConstants.defaultItemsPerPage
    private let maxItems = CoinGeckoConstants.maxTotalItems
    private var hasMoreData = true
    
    var canLoadMore: Bool {
        return hasMoreData && cryptocurrencies.count < maxItems && !isLoading && !isLoadingMore
    }
    
    init() {
        loadTopCryptocurrencies()
        loadFavorites()
    }
    
    func loadTopCryptocurrencies() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMoreData = true
        
        Task {
            do {
                let cryptos = try await coinGeckoService.fetchTopCryptocurrencies(page: currentPage, limit: itemsPerPage)
                await MainActor.run {
                    self.cryptocurrencies = cryptos
                    self.isLoading = false
                    // Always allow more loading after initial load unless we got nothing
                    self.hasMoreData = !cryptos.isEmpty
                }
            } catch let error as CoinGeckoError {
                await MainActor.run {
                    self.handleError(error)
                    self.isLoading = false
                    self.hasMoreData = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.isLoading = false
                    self.hasMoreData = false
                }
            }
        }
    }
    
    func loadMoreCryptocurrencies() {
        guard canLoadMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        Task {
            do {
                let newCryptos = try await coinGeckoService.fetchTopCryptocurrencies(page: currentPage, limit: itemsPerPage)
                await MainActor.run {
                    self.cryptocurrencies.append(contentsOf: newCryptos)
                    self.isLoadingMore = false
                    
                    // Continue loading until we get no new items OR reach exactly 100 items
                    self.hasMoreData = !newCryptos.isEmpty && self.cryptocurrencies.count < self.maxItems
                }
            } catch let error as CoinGeckoError {
                await MainActor.run {
                    self.isLoadingMore = false
                    self.currentPage -= 1 // Revert page increment on error
                    
                    // Only show error for non-retryable errors
                    if !error.isRetryable {
                        self.errorMessage = error.localizedDescription
                    }
                    self.hasMoreData = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingMore = false
                    self.currentPage -= 1 // Revert page increment on error
                    // Don't show error for pagination, just stop loading more
                    self.hasMoreData = false
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
            } catch let error as CoinGeckoError {
                await MainActor.run {
                    self.isFavoritesLoading = false
                    // Only show error for critical issues
                    if case .networkUnavailable = error {
                        self.errorMessage = error.localizedDescription
                    }
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
        guard trimmedQuery.count >= CoinGeckoConstants.minSearchQueryLength else {
            searchResults = []
            isSearching = false
            return
        }
        
        // Cancel previous search task
        searchTask?.cancel()
        
        isSearching = true
        
        searchTask = Task {
            // Add a small delay to avoid too many API calls
            try? await Task.sleep(nanoseconds: CoinGeckoConstants.searchDebounceDelay)
            
            guard !Task.isCancelled else { return }
            
            do {
                let results = try await coinGeckoService.searchCryptocurrencies(query: trimmedQuery)
                await MainActor.run {
                    if !Task.isCancelled {
                        self.searchResults = results
                        self.isSearching = false
                    }
                }
            } catch let error as CoinGeckoError {
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
    
    // MARK: - Error Handling
    
    private func handleError(_ error: CoinGeckoError) {
        switch error {
        case .networkUnavailable:
            self.errorMessage = CoinGeckoConstants.ErrorMessages.noInternet
        case .rateLimitExceeded(let retryAfter):
            self.errorMessage = "Too many requests. Please wait \(Int(retryAfter)) seconds before trying again."
        case .serverError(let code) where code >= 500:
            self.errorMessage = CoinGeckoConstants.ErrorMessages.serverUnavailable
        case .forbidden, .unauthorized:
            self.errorMessage = CoinGeckoConstants.ErrorMessages.accessDenied
        default:
            self.errorMessage = error.localizedDescription
        }
    }
} 