import SwiftUI

struct APIUsageDebugView: View {
    @StateObject private var coinLoreService = CoinLoreService.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Current Usage Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        InfoRow(title: "API Provider", value: "CoinLore")
                        InfoRow(title: "Base URL", value: "api.coinlore.net")
                        InfoRow(title: "Rate Limits", value: "No limits")
                        InfoRow(title: "Cost", value: "100% Free")
                        InfoRow(title: "Commercial Use", value: "Allowed")
                    }
                    .padding()
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Features Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Features")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        FeatureRow(title: "Top Cryptocurrencies", available: true)
                        FeatureRow(title: "Price & 24h Change", available: true)
                        FeatureRow(title: "Market Cap Data", available: true)
                        FeatureRow(title: "Search Functionality", available: true)
                        FeatureRow(title: "Pagination Support", available: true)
                        FeatureRow(title: "Volume Data", available: true)
                        FeatureRow(title: "Historical Data", available: false)
                    }
                    .padding()
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Pagination Info Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pagination Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        InfoRow(title: "Page Size", value: "50 coins")
                        InfoRow(title: "Max Per Request", value: "100 coins")
                        InfoRow(title: "Total Available", value: "~2000+ coins")
                        InfoRow(title: "Parameters", value: "start & limit")
                    }
                    .padding()
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Currency Conversion Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency Conversion")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        InfoRow(title: "Exchange Rate API", value: "fawazahmed0/currency-api")
                        InfoRow(title: "Primary Host", value: "cdn.jsdelivr.net")
                        InfoRow(title: "Fallback Host", value: "currency-api.pages.dev")
                        InfoRow(title: "Update Frequency", value: "Daily")
                        InfoRow(title: "Rate Limits", value: "No limits")
                        InfoRow(title: "Cost", value: "100% Free")
                        InfoRow(title: "Commercial Use", value: "Allowed (CC0 License)")
                        InfoRow(title: "Base Currency", value: "USD (from CoinLore)")
                        InfoRow(title: "Supported Currencies", value: "200+ currencies")
                        InfoRow(title: "Cache Duration", value: "1 hour")
                        InfoRow(title: "Fallback Mechanism", value: "Automatic")
                    }
                    .padding()
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Test Connection Button
                    Button(action: {
                        testConnection()
                    }) {
                        Text("Test API Connection")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("API Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func testConnection() {
        Task {
            do {
                _ = try await coinLoreService.fetchTopCryptocurrencies(limit: 1)
                // Connection successful
            } catch {
                // Handle error
                print("Connection test failed: \(error)")
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct FeatureRow: View {
    let title: String
    let available: Bool
    
    var body: some View {
        HStack {
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(available ? .green : .red)
                .font(.caption)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    APIUsageDebugView()
} 