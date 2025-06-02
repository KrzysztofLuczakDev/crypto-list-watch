//
//  FavoritesManager.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteNameids: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteCryptocurrencies"
    private let nameidsKey = "FavoriteCryptocurrencyNameids"
    private let migrationKey = "FavoritesMigratedToNameids"
    
    private init() {
        migrateToNameidsIfNeeded()
        loadFavorites()
    }
    
    private func migrateToNameidsIfNeeded() {
        // Check if we've already migrated to nameids
        guard !userDefaults.bool(forKey: migrationKey) else { 
            print("FavoritesManager: Already migrated to nameids")
            return 
        }
        
        print("FavoritesManager: Starting migration to nameids")
        
        // Clear any old favorites since we can't reliably convert numeric IDs to nameids
        // without making API calls, and we want a clean start
        userDefaults.removeObject(forKey: favoritesKey)
        userDefaults.removeObject(forKey: nameidsKey)
        
        // Mark migration as complete
        userDefaults.set(true, forKey: migrationKey)
        
        print("FavoritesManager: Migration to nameids completed - cleared old favorites")
    }
    
    private func loadFavorites() {
        let savedNameids = userDefaults.stringArray(forKey: nameidsKey) ?? []
        favoriteNameids = Set(savedNameids)
        print("FavoritesManager: Loaded \(favoriteNameids.count) favorite nameids: \(Array(favoriteNameids))")
    }
    
    private func saveFavorites() {
        userDefaults.set(Array(favoriteNameids), forKey: nameidsKey)
        print("FavoritesManager: Saved \(favoriteNameids.count) favorite nameids: \(Array(favoriteNameids))")
    }
    
    func isFavorite(_ cryptocurrency: Cryptocurrency) -> Bool {
        let result = favoriteNameids.contains(cryptocurrency.favoriteId)
        print("FavoritesManager: Checking if \(cryptocurrency.favoriteId) (\(cryptocurrency.name)) is favorite: \(result)")
        return result
    }
    
    func isFavoriteByNameid(_ nameid: String) -> Bool {
        let result = favoriteNameids.contains(nameid)
        print("FavoritesManager: Checking if nameid \(nameid) is favorite: \(result)")
        return result
    }
    
    func toggleFavorite(_ cryptocurrency: Cryptocurrency) {
        let nameid = cryptocurrency.favoriteId
        print("FavoritesManager: Toggling favorite for \(nameid) (\(cryptocurrency.name))")
        
        if favoriteNameids.contains(nameid) {
            favoriteNameids.remove(nameid)
            print("FavoritesManager: Removed \(nameid) from favorites")
        } else {
            favoriteNameids.insert(nameid)
            print("FavoritesManager: Added \(nameid) to favorites")
        }
        saveFavorites()
    }
    
    func addToFavorites(_ cryptocurrency: Cryptocurrency) {
        let nameid = cryptocurrency.favoriteId
        print("FavoritesManager: Adding \(nameid) (\(cryptocurrency.name)) to favorites")
        favoriteNameids.insert(nameid)
        saveFavorites()
    }
    
    func removeFromFavorites(_ cryptocurrency: Cryptocurrency) {
        let nameid = cryptocurrency.favoriteId
        print("FavoritesManager: Removing \(nameid) (\(cryptocurrency.name)) from favorites")
        favoriteNameids.remove(nameid)
        saveFavorites()
    }
    
    func getFavoriteNameidsList() -> [String] {
        let nameids = Array(favoriteNameids)
        print("FavoritesManager: Getting favorite nameids list: \(nameids)")
        return nameids
    }
    
    /// Clear all favorites (useful for debugging)
    func clearAllFavorites() {
        print("FavoritesManager: Clearing all favorites")
        favoriteNameids.removeAll()
        saveFavorites()
    }
} 