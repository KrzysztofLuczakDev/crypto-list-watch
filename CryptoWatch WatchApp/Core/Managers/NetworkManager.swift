//
//  NetworkManager.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation
import Combine

// MARK: - Network Manager Protocol

protocol NetworkManagerProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
    func requestData(_ endpoint: APIEndpoint) async throws -> Data
}

// MARK: - Network Manager

final class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Public Methods
    
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let data = try await requestData(endpoint)
        
        do {
            let response = try decoder.decode(T.self, from: data)
            return response
        } catch {
            throw AppError.decodingError("Failed to decode \(T.self): \(error.localizedDescription)")
        }
    }
    
    func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        guard let url = endpoint.url else {
            throw AppError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError("Invalid response")
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw AppError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            return data
        } catch {
            if error is AppError {
                throw error
            } else {
                throw AppError.networkError(error.localizedDescription)
            }
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - API Endpoint Protocol

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var url: URL? { get }
}

extension APIEndpoint {
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
} 