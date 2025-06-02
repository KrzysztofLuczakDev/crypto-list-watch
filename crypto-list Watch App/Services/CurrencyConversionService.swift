import Foundation

class CurrencyConversionService: ObservableObject {
    static let shared = CurrencyConversionService()
    
    private let session: URLSession
    private let cache = NSCache<NSString, NSNumber>()
    private var lastUpdateTime: Date?
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    // Primary and fallback URLs for the free currency API
    private let primaryBaseURL = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies"
    private let fallbackBaseURL = "https://latest.currency-api.pages.dev/v1/currencies"
    
    // Exchange rates relative to USD (1 USD = X currency)
    @Published private var exchangeRates: [String: Double] = [:]
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
        
        // Set default rates (fallback values)
        setDefaultRates()
    }
    
    // MARK: - Public Methods
    
    /// Convert USD amount to target currency
    func convertFromUSD(_ usdAmount: Double, to currency: CurrencyPreference) -> Double {
        // If target currency is USD, no conversion needed
        guard currency != .usd else { return usdAmount }
        
        // For crypto currencies, we need special handling
        if currency.isCrypto {
            return convertToCrypto(usdAmount, crypto: currency)
        }
        
        // For fiat currencies, use exchange rate
        let rate = getExchangeRate(for: currency)
        return usdAmount * rate
    }
    
    /// Get current exchange rate for a currency (1 USD = X currency)
    func getExchangeRate(for currency: CurrencyPreference) -> Double {
        guard currency != .usd else { return 1.0 }
        
        let key = currency.rawValue
        
        // Check cache first
        if let cachedRate = cache.object(forKey: key as NSString) {
            return cachedRate.doubleValue
        }
        
        // Return stored rate or default
        return exchangeRates[key] ?? getDefaultRate(for: currency)
    }
    
    /// Fetch latest exchange rates from API
    func updateExchangeRates() async {
        // Check if we need to update (don't update more than once per hour)
        if let lastUpdate = lastUpdateTime,
           Date().timeIntervalSince(lastUpdate) < cacheExpirationTime {
            return
        }
        
        do {
            let rates = try await fetchExchangeRates()
            
            await MainActor.run {
                self.exchangeRates = rates
                self.lastUpdateTime = Date()
                
                // Cache the rates
                for (currency, rate) in rates {
                    self.cache.setObject(NSNumber(value: rate), forKey: currency as NSString)
                }
            }
        } catch {
            print("Failed to update exchange rates: \(error)")
            // Keep using cached/default rates
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchExchangeRates() async throws -> [String: Double] {
        // Try primary URL first, then fallback
        let urls = [
            "\(primaryBaseURL)/usd.json",
            "\(fallbackBaseURL)/usd.json"
        ]
        
        var lastError: Error?
        
        for urlString in urls {
            do {
                guard let url = URL(string: urlString) else { continue }
                let (data, _) = try await session.data(from: url)
                let response = try JSONDecoder().decode(CurrencyAPIResponse.self, from: data)
                return response.usd
            } catch {
                lastError = error
                print("Failed to fetch from \(urlString): \(error)")
                continue
            }
        }
        
        throw lastError ?? CurrencyConversionError.noDataAvailable
    }
    
    private func convertToCrypto(_ usdAmount: Double, crypto: CurrencyPreference) -> Double {
        // For crypto conversions, we need the crypto price in USD
        // This is a simplified approach - in a real app you'd fetch current crypto prices
        let cryptoPriceInUSD = getCryptoPriceInUSD(crypto: crypto)
        return usdAmount / cryptoPriceInUSD
    }
    
    private func getCryptoPriceInUSD(crypto: CurrencyPreference) -> Double {
        // Simplified crypto prices (in a real app, fetch from API)
        // These are approximate values and should be updated regularly
        switch crypto {
        case .btc: return 45000.0
        case .eth: return 3000.0
        case .bnb: return 300.0
        case .ada: return 0.5
        case .dot: return 7.0
        case .sol: return 100.0
        default: return 1.0
        }
    }
    
    private func setDefaultRates() {
        // Default exchange rates (approximate values as fallback)
        exchangeRates = [
            "eur": 0.85,
            "gbp": 0.73,
            "jpy": 110.0,
            "cad": 1.25,
            "aud": 1.35,
            "chf": 0.92,
            "cny": 6.45,
            "nok": 8.5,
            "sek": 8.8,
            "dkk": 6.3,
            "pln": 3.9,
            "czk": 21.5,
            "huf": 295.0,
            "ron": 4.2,
            "bgn": 1.66,
            "hrk": 6.4,
            "rsd": 100.0,
            "isk": 125.0,
            "try": 8.5,
            "rub": 75.0,
            "uah": 27.0
        ]
    }
    
    private func getDefaultRate(for currency: CurrencyPreference) -> Double {
        return exchangeRates[currency.rawValue] ?? 1.0
    }
}

// MARK: - Response Models

struct CurrencyAPIResponse: Codable {
    let usd: [String: Double]
}

// MARK: - Error Types

enum CurrencyConversionError: Error, LocalizedError {
    case noDataAvailable
    case invalidResponse
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noDataAvailable:
            return "No currency data available"
        case .invalidResponse:
            return "Invalid response from currency API"
        case .networkError:
            return "Network error occurred"
        }
    }
} 