//
//  CryptoAPIEndpoints.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - Crypto API Endpoints

enum CryptoAPIEndpoint: APIEndpoint {
    case topCryptocurrencies(start: Int, limit: Int)
    case specificCryptocurrencies(ids: [String])
    case searchCryptocurrencies(query: String)
    
    var baseURL: String {
        return "https://api.coinlore.net/api"
    }
    
    var path: String {
        switch self {
        case .topCryptocurrencies:
            return "/tickers/"
        case .specificCryptocurrencies:
            return "/ticker/"
        case .searchCryptocurrencies:
            return "/tickers/"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .topCryptocurrencies(let start, let limit):
            return [
                URLQueryItem(name: "start", value: "\(start)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        case .specificCryptocurrencies(let ids):
            return [
                URLQueryItem(name: "id", value: ids.joined(separator: ","))
            ]
        case .searchCryptocurrencies(let query):
            return [
                URLQueryItem(name: "start", value: "0"),
                URLQueryItem(name: "limit", value: "100")
            ]
        }
    }
}

// MARK: - Currency API Endpoints

enum CurrencyAPIEndpoint: APIEndpoint {
    case exchangeRates
    case exchangeRatesFallback
    
    var baseURL: String {
        switch self {
        case .exchangeRates:
            return "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies"
        case .exchangeRatesFallback:
            return "https://latest.currency-api.pages.dev/v1/currencies"
        }
    }
    
    var path: String {
        return "/usd.json"
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
} 