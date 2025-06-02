//
//  CoinGeckoService.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation
import Network

class CoinGeckoService: ObservableObject {
    static let shared = CoinGeckoService()
    
    private let baseURL = CoinGeckoConstants.baseURL
    private let session: URLSession
    private let cache = NSCache<NSString, NSData>()
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    // Rate limiting
    private var requestCount = 0
    private var lastResetTime = Date()
    private let maxRequestsPerMinute = CoinGeckoConstants.maxRequestsPerMinute
    private let rateLimitQueue = DispatchQueue(label: "RateLimit", attributes: .concurrent)
    
    // Network status
    @Published var isNetworkAvailable = true
    
    private init() {
        // Configure URLSession for watchOS
        let configuration = URLSessionConfiguration.default
        
        // Timeout configuration
        configuration.timeoutIntervalForRequest = CoinGeckoConstants.requestTimeout
        configuration.timeoutIntervalForResource = CoinGeckoConstants.resourceTimeout
        
        // Network optimization for watchOS
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        configuration.allowsExpensiveNetworkAccess = true
        configuration.allowsConstrainedNetworkAccess = true
        
        // HTTP configuration
        configuration.httpMaximumConnectionsPerHost = CoinGeckoConstants.maxConnectionsPerHost
        configuration.requestCachePolicy = .useProtocolCachePolicy
        
        // Create session with custom configuration
        self.session = URLSession(configuration: configuration)
        
        // Configure cache
        cache.countLimit = CoinGeckoConstants.cacheCountLimit
        cache.totalCostLimit = CoinGeckoConstants.cacheSizeLimit
        
        // Start network monitoring
        startNetworkMonitoring()
    }
    
    deinit {
        pathMonitor.cancel()
    }
    
    private func startNetworkMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }
    
    // MARK: - Rate Limiting
    
    private func checkRateLimit() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            rateLimitQueue.async(flags: .barrier) {
                let now = Date()
                
                // Reset counter if a minute has passed
                if now.timeIntervalSince(self.lastResetTime) >= 60 {
                    self.requestCount = 0
                    self.lastResetTime = now
                }
                
                if self.requestCount >= self.maxRequestsPerMinute {
                    let waitTime = 60 - now.timeIntervalSince(self.lastResetTime)
                    continuation.resume(throwing: CoinGeckoError.rateLimitExceeded(retryAfter: waitTime))
                } else {
                    self.requestCount += 1
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Network Request with Retry
    
    private func performRequest<T: Codable>(
        url: URL,
        type: T.Type,
        cacheKey: String? = nil,
        maxRetries: Int = CoinGeckoConstants.maxRetryAttempts
    ) async throws -> T {
        // Check cache first
        if let cacheKey = cacheKey,
           let cachedData = cache.object(forKey: NSString(string: cacheKey)) {
            do {
                let result = try JSONDecoder().decode(T.self, from: cachedData as Data)
                return result
            } catch {
                // Cache data is corrupted, remove it
                cache.removeObject(forKey: NSString(string: cacheKey))
            }
        }
        
        // Check network availability
        guard isNetworkAvailable else {
            throw CoinGeckoError.networkUnavailable
        }
        
        // Check rate limit
        try await checkRateLimit()
        
        // Perform request with retry logic
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                let data = try await performSingleRequest(url: url)
                let result = try JSONDecoder().decode(T.self, from: data)
                
                // Cache successful result
                if let cacheKey = cacheKey {
                    cache.setObject(NSData(data: data), forKey: NSString(string: cacheKey))
                }
                
                return result
                
            } catch let error as CoinGeckoError {
                lastError = error
                
                // Don't retry for certain errors
                switch error {
                case .invalidURL, .decodingError, .rateLimitExceeded:
                    throw error
                case .serverError(let code) where code == 401 || code == 403:
                    throw error
                default:
                    break
                }
                
                // Wait before retry with exponential backoff
                if attempt < maxRetries - 1 {
                    let delay = min(pow(2.0, Double(attempt)) * 1.0, CoinGeckoConstants.maxRetryDelay)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
                
            } catch {
                lastError = error
                
                // Wait before retry
                if attempt < maxRetries - 1 {
                    let delay = min(pow(2.0, Double(attempt)) * 1.0, CoinGeckoConstants.maxRetryDelay)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? CoinGeckoError.networkError("Unknown error after \(maxRetries) retries")
    }
    
    private func performSingleRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        
        // Set proper headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(CoinGeckoConstants.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        
        // Set cache policy
        request.cachePolicy = .returnCacheDataElseLoad
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CoinGeckoError.invalidResponse
        }
        
        // Handle different status codes
        switch httpResponse.statusCode {
        case 200:
            return data
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Double.init) ?? 60
            throw CoinGeckoError.rateLimitExceeded(retryAfter: retryAfter)
        case 400:
            throw CoinGeckoError.badRequest
        case 401:
            throw CoinGeckoError.unauthorized
        case 403:
            throw CoinGeckoError.forbidden
        case 404:
            throw CoinGeckoError.notFound
        case 500...599:
            throw CoinGeckoError.serverError(httpResponse.statusCode)
        default:
            throw CoinGeckoError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Public API Methods
    
    func fetchTopCryptocurrencies(limit: Int = CoinGeckoConstants.defaultItemsPerPage, currency: String = CoinGeckoConstants.QueryParams.defaultVsCurrency) async throws -> [Cryptocurrency] {
        let urlString = CoinGeckoConstants.marketsURL(page: 1, limit: limit, currency: currency)
        
        guard let url = URL(string: urlString) else {
            throw CoinGeckoError.invalidURL
        }
        
        let cacheKey = CoinGeckoConstants.topCryptosCacheKey(limit: limit, currency: currency)
        return try await performRequest(url: url, type: [Cryptocurrency].self, cacheKey: cacheKey)
    }
    
    func fetchTopCryptocurrencies(page: Int, limit: Int = CoinGeckoConstants.defaultItemsPerPage, currency: String = CoinGeckoConstants.QueryParams.defaultVsCurrency) async throws -> [Cryptocurrency] {
        let urlString = CoinGeckoConstants.marketsURL(page: page, limit: limit, currency: currency)
        
        guard let url = URL(string: urlString) else {
            throw CoinGeckoError.invalidURL
        }
        
        let cacheKey = CoinGeckoConstants.topCryptosPageCacheKey(page: page, limit: limit, currency: currency)
        return try await performRequest(url: url, type: [Cryptocurrency].self, cacheKey: cacheKey)
    }
    
    func fetchCryptocurrenciesByIds(_ ids: [String], currency: String = CoinGeckoConstants.QueryParams.defaultVsCurrency) async throws -> [Cryptocurrency] {
        guard !ids.isEmpty else {
            return []
        }
        
        let urlString = CoinGeckoConstants.marketsURLByIds(ids: ids, currency: currency)
        
        guard let url = URL(string: urlString) else {
            throw CoinGeckoError.invalidURL
        }
        
        let cacheKey = CoinGeckoConstants.cryptosByIdsCacheKey(ids: ids, currency: currency)
        return try await performRequest(url: url, type: [Cryptocurrency].self, cacheKey: cacheKey)
    }
    
    func searchCryptocurrencies(query: String) async throws -> [Cryptocurrency] {
        // First, search for coins using the search endpoint
        let searchUrlString = CoinGeckoConstants.searchURL(query: query)
        
        guard let searchUrl = URL(string: searchUrlString) else {
            throw CoinGeckoError.invalidURL
        }
        
        let searchResult = try await performRequest(url: searchUrl, type: SearchResponse.self)
        
        // Get the first N coin IDs from search results
        let coinIds = Array(searchResult.coins.prefix(CoinGeckoConstants.maxSearchResults)).map { $0.id }
        
        if coinIds.isEmpty {
            return []
        }
        
        // Now fetch market data for these coins (using default currency for search)
        return try await fetchCryptocurrenciesByIds(coinIds)
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func getCacheSize() -> Int {
        return cache.totalCostLimit
    }
}

enum CoinGeckoError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkUnavailable
    case rateLimitExceeded(retryAfter: Double)
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case networkError(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkUnavailable:
            return "No internet connection available"
        case .rateLimitExceeded(let retryAfter):
            return "Rate limit exceeded. Try again in \(Int(retryAfter)) seconds"
        case .badRequest:
            return "Invalid request parameters"
        case .unauthorized:
            return "API key required or invalid"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error (\(code))"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data parsing error: \(message)"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .serverError, .networkUnavailable:
            return true
        case .rateLimitExceeded:
            return true
        default:
            return false
        }
    }
}

// Search response models
struct SearchResponse: Codable {
    let coins: [SearchCoin]
}

struct SearchCoin: Codable {
    let id: String
    let name: String
    let symbol: String
} 