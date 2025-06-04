import Foundation
import Network

class CoinLoreService: ObservableObject {
    static let shared = CoinLoreService()
    
    private let baseURL = "https://api.coinlore.net/api"
    private let session: URLSession
    private let cache = NSCache<NSString, NSData>()
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private let currencyService = CurrencyConversionService.shared
    
    @Published var isConnected = true
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
        
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }
    
    deinit {
        pathMonitor.cancel()
    }
    
    // MARK: - API Methods
    
    /// Fetch top cryptocurrencies
    func fetchTopCryptocurrencies(limit: Int = 100) async throws -> [Cryptocurrency] {
        return try await fetchTopCryptocurrencies(start: 0, limit: limit)
    }
    
    /// Fetch top cryptocurrencies with pagination
    func fetchTopCryptocurrencies(start: Int, limit: Int = 100) async throws -> [Cryptocurrency] {
        let cacheKey = "top_crypto_\(start)_\(limit)" as NSString
        
        // Update exchange rates in background (don't wait for it)
        Task {
            await currencyService.updateExchangeRates()
        }
        
        // Check cache first (with shorter cache time for paginated data)
        if let cachedData = cache.object(forKey: cacheKey) {
            let decoder = JSONDecoder()
            let response = try decoder.decode(CoinLoreTickersResponse.self, from: cachedData as Data)
            return response.data.map { $0.toCryptocurrency() }
        }
        
        let url = URL(string: "\(baseURL)/tickers/?start=\(start)&limit=\(limit)")!
        let data = try await performRequest(url: url)
        
        // Cache the response for 30 seconds (shorter for paginated data)
        cache.setObject(data as NSData, forKey: cacheKey)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(CoinLoreTickersResponse.self, from: data)
        return response.data.map { $0.toCryptocurrency() }
    }
    
    /// Get total number of available coins
    func getTotalCoinsCount() async throws -> Int {
        // Fetch first page to get total count from info
        let url = URL(string: "\(baseURL)/tickers/?start=0&limit=1")!
        let data = try await performRequest(url: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(CoinLoreTickersResponse.self, from: data)
        return response.info.coinsNum
    }
    
    /// Fetch specific cryptocurrency by ID
    func fetchCryptocurrency(id: String) async throws -> Cryptocurrency {
        let cacheKey = "crypto_\(id)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey) {
            let decoder = JSONDecoder()
            let response = try decoder.decode([CoinLoreTicker].self, from: cachedData as Data)
            if let ticker = response.first {
                return ticker.toCryptocurrency()
            }
        }
        
        let url = URL(string: "\(baseURL)/ticker/?id=\(id)")!
        let data = try await performRequest(url: url)
        
        // Cache the response
        cache.setObject(data as NSData, forKey: cacheKey)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode([CoinLoreTicker].self, from: data)
        
        guard let ticker = response.first else {
            throw CoinLoreError.invalidResponse
        }
        
        return ticker.toCryptocurrency()
    }
    
    /// Fetch multiple cryptocurrencies by IDs
    func fetchCryptocurrencies(ids: [String]) async throws -> [Cryptocurrency] {
        print("CoinLoreService: Fetching cryptocurrencies for IDs: \(ids)")
        let idsString = ids.joined(separator: ",")
        let url = URL(string: "\(baseURL)/ticker/?id=\(idsString)")!
        print("CoinLoreService: Request URL: \(url)")
        
        let data = try await performRequest(url: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode([CoinLoreTicker].self, from: data)
        print("CoinLoreService: Received \(response.count) tickers from API")
        
        let cryptocurrencies = response.map { $0.toCryptocurrency() }
        print("CoinLoreService: Converted to \(cryptocurrencies.count) cryptocurrencies")
        
        return cryptocurrencies
    }
    
    /// Fetch cryptocurrencies by nameids (more reliable for favorites)
    func fetchCryptocurrenciesByNameids(nameids: [String]) async throws -> [Cryptocurrency] {
        print("CoinLoreService: Fetching cryptocurrencies by nameids: \(nameids)")
        
        // First, we need to get all coins and find the numeric IDs for these nameids
        // We'll search through a reasonable number of top coins to find matches
        let searchLimit = 1000 // Search through top 1000 coins
        let allCryptos = try await fetchTopCryptocurrencies(start: 0, limit: searchLimit)
        
        // Find matching cryptocurrencies by nameid
        let matchingCryptos = allCryptos.filter { crypto in
            nameids.contains(crypto.nameid)
        }
        
        print("CoinLoreService: Found \(matchingCryptos.count) matching cryptocurrencies for nameids")
        return matchingCryptos
    }
    
    /// Search for a specific cryptocurrency by nameid
    func searchCryptocurrencyByNameid(nameid: String) async throws -> Cryptocurrency? {
        print("CoinLoreService: Searching for cryptocurrency with nameid: \(nameid)")
        
        // Search through top coins to find the one with matching nameid
        let searchLimit = 1000
        let allCryptos = try await fetchTopCryptocurrencies(start: 0, limit: searchLimit)
        
        let matchingCrypto = allCryptos.first { crypto in
            crypto.nameid == nameid
        }
        
        if let crypto = matchingCrypto {
            print("CoinLoreService: Found cryptocurrency: \(crypto.name) (\(crypto.symbol))")
        } else {
            print("CoinLoreService: No cryptocurrency found with nameid: \(nameid)")
        }
        
        return matchingCrypto
    }
    
    /// Search cryptocurrencies (using the tickers endpoint with filtering)
    func searchCryptocurrencies(query: String) async throws -> [Cryptocurrency] {
        // CoinLore doesn't have a dedicated search endpoint, so we'll fetch a reasonable amount and filter
        // We'll search through the top 1000 coins to cover more use cases
        let searchLimit = 1000
        let allCryptos = try await fetchTopCryptocurrencies(start: 0, limit: searchLimit)
        let lowercaseQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !lowercaseQuery.isEmpty else { return [] }
        
        // Filter and score results based on relevance
        let scoredResults = allCryptos.compactMap { crypto -> (crypto: Cryptocurrency, score: Int)? in
            let lowercaseName = crypto.name.lowercased()
            let lowercaseSymbol = crypto.symbol.lowercased()
            let lowercaseNameid = crypto.nameid.lowercased()
            
            var score = 0
            
            // Exact matches get highest priority
            if lowercaseName == lowercaseQuery {
                score = 1000 // Exact name match
            } else if lowercaseSymbol == lowercaseQuery {
                score = 900 // Exact symbol match
            } else if lowercaseNameid == lowercaseQuery {
                score = 850 // Exact nameid match
            }
            // Starts with matches get high priority
            else if lowercaseName.hasPrefix(lowercaseQuery) {
                score = 800 // Name starts with query
            } else if lowercaseSymbol.hasPrefix(lowercaseQuery) {
                score = 700 // Symbol starts with query
            } else if lowercaseNameid.hasPrefix(lowercaseQuery) {
                score = 650 // Nameid starts with query
            }
            // Contains matches get medium priority
            else if lowercaseName.contains(lowercaseQuery) {
                score = 500 // Name contains query
            } else if lowercaseSymbol.contains(lowercaseQuery) {
                score = 400 // Symbol contains query
            } else if lowercaseNameid.contains(lowercaseQuery) {
                score = 350 // Nameid contains query
            }
            
            // Boost score for higher ranked coins (lower rank number = higher score boost)
            if score > 0 {
                let rankBoost = max(0, 100 - (crypto.marketCapRank ?? 1000))
                score += rankBoost
                return (crypto: crypto, score: score)
            }
            
            return nil
        }
        
        // Sort by score (highest first) and return the cryptocurrencies
        let sortedResults = scoredResults
            .sorted { $0.score > $1.score }
            .map { $0.crypto }
        
        print("CoinLoreService: Search for '\(query)' returned \(sortedResults.count) results")
        
        // Limit results to top 50 for performance
        return Array(sortedResults.prefix(50))
    }
    
    /// Search for a specific cryptocurrency by name (exact or partial match)
    func searchCryptocurrencyByName(name: String) async throws -> [Cryptocurrency] {
        print("CoinLoreService: Searching for cryptocurrency with name: \(name)")
        
        // Use the enhanced search function
        let results = try await searchCryptocurrencies(query: name)
        
        print("CoinLoreService: Found \(results.count) cryptocurrencies matching name '\(name)'")
        return results
    }
    
    // MARK: - Helper Methods
    
    private func performRequest(url: URL) async throws -> Data {
        guard isConnected else {
            throw CoinLoreError.noInternetConnection
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CoinLoreError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 429:
                throw CoinLoreError.rateLimitExceeded
            case 500...599:
                throw CoinLoreError.serverError
            default:
                throw CoinLoreError.invalidResponse
            }
        } catch {
            if error is CoinLoreError {
                throw error
            } else {
                throw CoinLoreError.networkError(error)
            }
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Data Models

struct CoinLoreTickersResponse: Codable {
    let data: [CoinLoreTicker]
    let info: CoinLoreInfo
}

struct CoinLoreInfo: Codable {
    let coinsNum: Int
    let time: Int
    
    enum CodingKeys: String, CodingKey {
        case coinsNum = "coins_num"
        case time
    }
}

struct CoinLoreTicker: Codable {
    let id: String
    let symbol: String
    let name: String
    let nameid: String
    let rank: Int
    let priceUsd: String
    let percentChange24h: String
    let percentChange1h: String
    let percentChange7d: String
    let priceBtc: String
    let marketCapUsd: String
    let volume24: Double
    let volume24a: Double?
    let csupply: String
    let tsupply: String?
    let msupply: String?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, nameid, rank
        case priceUsd = "price_usd"
        case percentChange24h = "percent_change_24h"
        case percentChange1h = "percent_change_1h"
        case percentChange7d = "percent_change_7d"
        case priceBtc = "price_btc"
        case marketCapUsd = "market_cap_usd"
        case volume24, volume24a, csupply, tsupply, msupply
    }
    
    func toCryptocurrency() -> Cryptocurrency {
        return Cryptocurrency(
            id: id,
            nameid: nameid,
            symbol: symbol.uppercased(),
            name: name,
            image: "", // No icons needed
            currentPrice: Double(priceUsd) ?? 0.0,
            marketCap: Double(marketCapUsd),
            marketCapRank: rank,
            priceChangePercentage24h: Double(percentChange24h),
            totalVolume: volume24
        )
    }
    
    private func calculatePriceChange24h() -> Double {
        let currentPrice = Double(priceUsd) ?? 0.0
        let changePercent = Double(percentChange24h) ?? 0.0
        return currentPrice * (changePercent / 100.0)
    }
}

// MARK: - Error Handling

enum CoinLoreError: Error, LocalizedError {
    case invalidResponse
    case noInternetConnection
    case rateLimitExceeded
    case serverError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .noInternetConnection:
            return "No internet connection"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .serverError:
            return "Server error"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 