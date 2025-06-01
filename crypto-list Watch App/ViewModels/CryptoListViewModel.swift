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
    @Published var searchResults: [Cryptocurrency] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var isSearching = false
    
    private let coinGeckoService = CoinGeckoService.shared
    private var searchTask: Task<Void, Never>?
    
    init() {
        loadTopCryptocurrencies()
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
    
    func searchCryptocurrencies() {
        guard !searchText.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        // Cancel previous search task
        searchTask?.cancel()
        
        isSearching = true
        
        searchTask = Task {
            // Add a small delay to avoid too many API calls
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            guard !Task.isCancelled else { return }
            
            do {
                let results = try await coinGeckoService.searchCryptocurrencies(query: searchText)
                await MainActor.run {
                    if !Task.isCancelled {
                        self.searchResults = results
                        self.isSearching = false
                    }
                }
            } catch {
                await MainActor.run {
                    if !Task.isCancelled {
                        self.errorMessage = error.localizedDescription
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
        loadTopCryptocurrencies()
    }
} 