//
//  FavoritesManager.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - Favorites Manager Protocol

protocol FavoritesManagerProtocol: ObservableObject {
    var favoriteNameids: Set<String> { get }
    
    func isFavorite(_ cryptocurrency: Cryptocurrency) -> Bool
    func toggleFavorite(_ cryptocurrency: Cryptocurrency)
    func addToFavorites(_ cryptocurrency: Cryptocurrency)
    func removeFromFavorites(_ cryptocurrency: Cryptocurrency)
    func getFavoriteNameidsList() -> [String]
    func clearAllFavorites()
}

// MARK: - Favorites Manager

final class FavoritesManager: FavoritesManagerProtocol {
    static let shared = FavoritesManager()
    
    @Published var favoriteNameids: Set<String> = []
    
    // Use App Groups for sharing data between app and widget
    private let userDefaults = UserDefaults(suiteName: "group.krzysztof-luczak.crypto-watch") ?? UserDefaults.standard
    private let favoritesKey = "FavoriteCryptocurrencies"
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Private Methods
    
    private func loadFavorites() {
        let savedFavorites = userDefaults.stringArray(forKey: favoritesKey) ?? []
        favoriteNameids = Set(savedFavorites)
        print("FavoritesManager: Loaded \(favoriteNameids.count) favorites: \(favoriteNameids)")
    }
    
    private func saveFavorites() {
        userDefaults.set(Array(favoriteNameids), forKey: favoritesKey)
        print("FavoritesManager: Saved \(favoriteNameids.count) favorites: \(favoriteNameids)")
    }
    
    // MARK: - Public Methods
    
    func isFavorite(_ cryptocurrency: Cryptocurrency) -> Bool {
        return favoriteNameids.contains(cryptocurrency.nameid)
    }
    
    func toggleFavorite(_ cryptocurrency: Cryptocurrency) {
        print("FavoritesManager: Toggling favorite for \(cryptocurrency.name) (nameid: \(cryptocurrency.nameid))")
        
        if favoriteNameids.contains(cryptocurrency.nameid) {
            favoriteNameids.remove(cryptocurrency.nameid)
            print("FavoritesManager: Removed \(cryptocurrency.name) from favorites")
        } else {
            favoriteNameids.insert(cryptocurrency.nameid)
            print("FavoritesManager: Added \(cryptocurrency.name) to favorites")
        }
        saveFavorites()
    }
    
    func addToFavorites(_ cryptocurrency: Cryptocurrency) {
        print("FavoritesManager: Adding \(cryptocurrency.name) (nameid: \(cryptocurrency.nameid)) to favorites")
        favoriteNameids.insert(cryptocurrency.nameid)
        saveFavorites()
    }
    
    func removeFromFavorites(_ cryptocurrency: Cryptocurrency) {
        print("FavoritesManager: Removing \(cryptocurrency.name) (nameid: \(cryptocurrency.nameid)) from favorites")
        favoriteNameids.remove(cryptocurrency.nameid)
        saveFavorites()
    }
    
    func getFavoriteNameidsList() -> [String] {
        return Array(favoriteNameids)
    }
    
    func clearAllFavorites() {
        print("FavoritesManager: Clearing all favorites")
        favoriteNameids.removeAll()
        saveFavorites()
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    
    func isFavorite(_ cryptoId: String) -> Bool {
        return favoriteNameids.contains(cryptoId)
    }
    
    func toggleFavorite(_ cryptoId: String) {
        if favoriteNameids.contains(cryptoId) {
            favoriteNameids.remove(cryptoId)
        } else {
            favoriteNameids.insert(cryptoId)
        }
        saveFavorites()
    }
    
    func addToFavorites(_ cryptoId: String) {
        favoriteNameids.insert(cryptoId)
        saveFavorites()
    }
    
    func removeFromFavorites(_ cryptoId: String) {
        favoriteNameids.remove(cryptoId)
        saveFavorites()
    }
    
    func getFavoritesList() -> [String] {
        return Array(favoriteNameids)
    }
}

// MARK: - Mock Favorites Manager for Testing

final class MockFavoritesManager: FavoritesManagerProtocol {
    @Published var favoriteNameids: Set<String> = []
    
    func isFavorite(_ cryptocurrency: Cryptocurrency) -> Bool {
        return favoriteNameids.contains(cryptocurrency.nameid)
    }
    
    func toggleFavorite(_ cryptocurrency: Cryptocurrency) {
        if favoriteNameids.contains(cryptocurrency.nameid) {
            favoriteNameids.remove(cryptocurrency.nameid)
        } else {
            favoriteNameids.insert(cryptocurrency.nameid)
        }
    }
    
    func addToFavorites(_ cryptocurrency: Cryptocurrency) {
        favoriteNameids.insert(cryptocurrency.nameid)
    }
    
    func removeFromFavorites(_ cryptocurrency: Cryptocurrency) {
        favoriteNameids.remove(cryptocurrency.nameid)
    }
    
    func getFavoriteNameidsList() -> [String] {
        return Array(favoriteNameids)
    }
    
    func clearAllFavorites() {
        favoriteNameids.removeAll()
    }
} 