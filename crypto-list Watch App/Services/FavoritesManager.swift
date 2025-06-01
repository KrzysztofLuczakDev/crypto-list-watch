//
//  FavoritesManager.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteIds: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteCryptocurrencies"
    
    private init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        let savedFavorites = userDefaults.stringArray(forKey: favoritesKey) ?? []
        favoriteIds = Set(savedFavorites)
    }
    
    private func saveFavorites() {
        userDefaults.set(Array(favoriteIds), forKey: favoritesKey)
    }
    
    func isFavorite(_ cryptoId: String) -> Bool {
        return favoriteIds.contains(cryptoId)
    }
    
    func toggleFavorite(_ cryptoId: String) {
        if favoriteIds.contains(cryptoId) {
            favoriteIds.remove(cryptoId)
        } else {
            favoriteIds.insert(cryptoId)
        }
        saveFavorites()
    }
    
    func addToFavorites(_ cryptoId: String) {
        favoriteIds.insert(cryptoId)
        saveFavorites()
    }
    
    func removeFromFavorites(_ cryptoId: String) {
        favoriteIds.remove(cryptoId)
        saveFavorites()
    }
    
    func getFavoritesList() -> [String] {
        return Array(favoriteIds)
    }
} 