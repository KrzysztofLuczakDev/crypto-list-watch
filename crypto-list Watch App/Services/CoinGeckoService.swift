//
//  CoinGeckoService.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

class CoinGeckoService: ObservableObject {
    static let shared = CoinGeckoService()
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let session = URLSession.shared
    
    private init() {}
    
    func fetchTopCryptocurrencies(limit: Int = 10) async throws -> [Cryptocurrency] {
        let urlString = "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(limit)&page=1&sparkline=false&price_change_percentage=24h"
        
        guard let url = URL(string: urlString) else {
            throw CoinGeckoError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CoinGeckoError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw CoinGeckoError.serverError(httpResponse.statusCode)
            }
            
            let cryptocurrencies = try JSONDecoder().decode([Cryptocurrency].self, from: data)
            return cryptocurrencies
            
        } catch let error as DecodingError {
            throw CoinGeckoError.decodingError(error.localizedDescription)
        } catch {
            throw CoinGeckoError.networkError(error.localizedDescription)
        }
    }
    
    func fetchCryptocurrenciesByIds(_ ids: [String]) async throws -> [Cryptocurrency] {
        guard !ids.isEmpty else {
            return []
        }
        
        let idsString = ids.joined(separator: ",")
        let urlString = "\(baseURL)/coins/markets?vs_currency=usd&ids=\(idsString)&order=market_cap_desc&per_page=\(ids.count)&page=1&sparkline=false&price_change_percentage=24h"
        
        guard let url = URL(string: urlString) else {
            throw CoinGeckoError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CoinGeckoError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw CoinGeckoError.serverError(httpResponse.statusCode)
            }
            
            let cryptocurrencies = try JSONDecoder().decode([Cryptocurrency].self, from: data)
            return cryptocurrencies
            
        } catch let error as DecodingError {
            throw CoinGeckoError.decodingError(error.localizedDescription)
        } catch {
            throw CoinGeckoError.networkError(error.localizedDescription)
        }
    }
    
    func searchCryptocurrencies(query: String) async throws -> [Cryptocurrency] {
        // First, search for coins using the search endpoint
        let searchUrlString = "\(baseURL)/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let searchUrl = URL(string: searchUrlString) else {
            throw CoinGeckoError.invalidURL
        }
        
        do {
            let (searchData, searchResponse) = try await session.data(from: searchUrl)
            
            guard let httpSearchResponse = searchResponse as? HTTPURLResponse else {
                throw CoinGeckoError.invalidResponse
            }
            
            guard httpSearchResponse.statusCode == 200 else {
                throw CoinGeckoError.serverError(httpSearchResponse.statusCode)
            }
            
            let searchResult = try JSONDecoder().decode(SearchResponse.self, from: searchData)
            
            // Get the first 10 coin IDs from search results
            let coinIds = Array(searchResult.coins.prefix(10)).map { $0.id }
            
            if coinIds.isEmpty {
                return []
            }
            
            // Now fetch market data for these coins
            let idsString = coinIds.joined(separator: ",")
            let marketUrlString = "\(baseURL)/coins/markets?vs_currency=usd&ids=\(idsString)&order=market_cap_desc&per_page=10&page=1&sparkline=false&price_change_percentage=24h"
            
            guard let marketUrl = URL(string: marketUrlString) else {
                throw CoinGeckoError.invalidURL
            }
            
            let (marketData, marketResponse) = try await session.data(from: marketUrl)
            
            guard let httpMarketResponse = marketResponse as? HTTPURLResponse else {
                throw CoinGeckoError.invalidResponse
            }
            
            guard httpMarketResponse.statusCode == 200 else {
                throw CoinGeckoError.serverError(httpMarketResponse.statusCode)
            }
            
            let cryptocurrencies = try JSONDecoder().decode([Cryptocurrency].self, from: marketData)
            return cryptocurrencies
            
        } catch let error as DecodingError {
            throw CoinGeckoError.decodingError(error.localizedDescription)
        } catch {
            throw CoinGeckoError.networkError(error.localizedDescription)
        }
    }
}

enum CoinGeckoError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        }
    }
}

// Add search response models
struct SearchResponse: Codable {
    let coins: [SearchCoin]
}

struct SearchCoin: Codable {
    let id: String
    let name: String
    let symbol: String
} 