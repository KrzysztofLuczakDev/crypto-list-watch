import Foundation

/// Utility class to help test API usage tracking
/// This is for development/testing purposes only
class APIUsageTester {
    static let shared = APIUsageTester()
    private let coinGeckoService = CoinGeckoService.shared
    
    private init() {}
    
    /// Simulates typical user behavior for testing API usage
    func simulateTypicalUsage() async {
        print("🧪 Starting API usage simulation...")
        
        // Simulate app launch - fetch top cryptocurrencies
        do {
            _ = try await coinGeckoService.fetchTopCryptocurrencies(limit: 25)
            print("✅ Simulated: App launch - top cryptocurrencies")
        } catch {
            print("❌ Failed to simulate app launch: \(error)")
        }
        
        // Wait a bit
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Simulate user scrolling - load more data
        do {
            _ = try await coinGeckoService.fetchTopCryptocurrencies(page: 2, limit: 25)
            print("✅ Simulated: User scrolling - page 2")
        } catch {
            print("❌ Failed to simulate scrolling: \(error)")
        }
        
        // Wait a bit
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Simulate search
        do {
            _ = try await coinGeckoService.searchCryptocurrencies(query: "bitcoin")
            print("✅ Simulated: Search for 'bitcoin'")
        } catch {
            print("❌ Failed to simulate search: \(error)")
        }
        
        // Wait a bit
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Simulate another search
        do {
            _ = try await coinGeckoService.searchCryptocurrencies(query: "ethereum")
            print("✅ Simulated: Search for 'ethereum'")
        } catch {
            print("❌ Failed to simulate search: \(error)")
        }
        
        print("🧪 API usage simulation completed!")
    }
    
    /// Simulates heavy usage for testing rate limits and projections
    func simulateHeavyUsage() async {
        print("🧪 Starting heavy API usage simulation...")
        
        for i in 1...10 {
            do {
                _ = try await coinGeckoService.fetchTopCryptocurrencies(page: i, limit: 10)
                print("✅ Heavy usage simulation: Request \(i)/10")
                
                // Small delay to respect rate limits
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            } catch {
                print("❌ Heavy usage simulation failed at request \(i): \(error)")
                break
            }
        }
        
        print("🧪 Heavy API usage simulation completed!")
    }
    
    /// Simulates a full day of typical usage
    func simulateFullDayUsage() async {
        print("🧪 Starting full day usage simulation...")
        
        // Morning check (8 AM)
        await simulateSessionUsage(sessionName: "Morning check")
        
        // Lunch break check (12 PM)
        await simulateSessionUsage(sessionName: "Lunch break")
        
        // Afternoon check (3 PM)
        await simulateSessionUsage(sessionName: "Afternoon check")
        
        // Evening check (7 PM)
        await simulateSessionUsage(sessionName: "Evening check")
        
        // Night check (10 PM)
        await simulateSessionUsage(sessionName: "Night check")
        
        print("🧪 Full day usage simulation completed!")
    }
    
    private func simulateSessionUsage(sessionName: String) async {
        print("📱 Simulating: \(sessionName)")
        
        // App launch
        do {
            _ = try await coinGeckoService.fetchTopCryptocurrencies(limit: 25)
        } catch {
            print("❌ \(sessionName) - App launch failed: \(error)")
        }
        
        // Small delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Maybe scroll for more data (50% chance)
        if Bool.random() {
            do {
                _ = try await coinGeckoService.fetchTopCryptocurrencies(page: 2, limit: 25)
            } catch {
                print("❌ \(sessionName) - Scrolling failed: \(error)")
            }
        }
        
        // Maybe search (30% chance)
        if Bool.random() && Bool.random() {
            let searchTerms = ["bitcoin", "ethereum", "cardano", "solana", "dogecoin"]
            let randomTerm = searchTerms.randomElement() ?? "bitcoin"
            
            do {
                _ = try await coinGeckoService.searchCryptocurrencies(query: randomTerm)
            } catch {
                print("❌ \(sessionName) - Search failed: \(error)")
            }
        }
        
        print("✅ \(sessionName) completed")
    }
    
    /// Gets current usage statistics for testing
    func printCurrentUsage() {
        let stats = coinGeckoService.getUsageStatistics()
        
        print("📊 Current API Usage Statistics:")
        print("   Daily: \(stats.dailyRequests)")
        print("   Monthly: \(stats.monthlyRequests)")
        print("   Total: \(stats.totalRequests)")
        print("   Average daily: \(String(format: "%.1f", stats.averageDailyRequests))")
        print("   Projected monthly: \(stats.projectedMonthlyRequests)")
        print("   Recommended plan: \(stats.getRecommendedPlan())")
        
        if !stats.endpointBreakdown.isEmpty {
            print("   Endpoint breakdown:")
            for (endpoint, count) in stats.endpointBreakdown.sorted(by: { $0.value > $1.value }) {
                print("     \(endpoint): \(count)")
            }
        }
    }
} 