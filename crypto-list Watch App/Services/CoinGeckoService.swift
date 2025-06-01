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
    
    func searchCryptocurrencies(query: String) async throws -> [Cryptocurrency] {
        let urlString = "\(baseURL)/coins/markets?vs_currency=usd&ids=\(query.lowercased())&order=market_cap_desc&per_page=50&page=1&sparkline=false&price_change_percentage=24h"
        
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
            return cryptocurrencies.filter { crypto in
                crypto.name.lowercased().contains(query.lowercased()) ||
                crypto.symbol.lowercased().contains(query.lowercased())
            }
            
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