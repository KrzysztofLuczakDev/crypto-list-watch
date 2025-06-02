import SwiftUI

struct APIUsageDebugView: View {
    @StateObject private var coinGeckoService = CoinGeckoService.shared
    @State private var usageStats: APIUsageStatistics?
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let stats = usageStats {
                        // Current Usage Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Usage")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Today")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(stats.dailyRequests)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("This Month")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(stats.monthlyRequests)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total Ever")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(stats.totalRequests)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Daily Average")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.1f", stats.averageDailyRequests))")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Projection Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Projection")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(stats.projectedMonthlyRequests) calls/month")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text("Based on current usage patterns")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .cornerRadius(12)
                        
                        // Recommended Plan Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recommended Plan")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(stats.getRecommendedPlan())
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .cornerRadius(12)
                        
                        // Endpoint Breakdown
                        if !stats.endpointBreakdown.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Endpoint Usage")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                ForEach(Array(stats.endpointBreakdown.sorted(by: { $0.value > $1.value })), id: \.key) { endpoint, count in
                                    HStack {
                                        Text(endpoint)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(count)")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // App Store Guidelines
                        VStack(alignment: .leading, spacing: 8) {
                            Text("App Store Guidelines")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Free tier: OK for personal/non-commercial apps")
                                Text("• Paid tier: Required for commercial apps")
                                Text("• Rate limiting: Your app respects 25 calls/minute")
                                Text("• Caching: Implemented to reduce API calls")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .cornerRadius(12)
                        
                        // Reset Button
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            Text("Reset Analytics")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                        .alert("Reset Analytics", isPresented: $showingResetAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Reset", role: .destructive) {
                                coinGeckoService.resetAnalytics()
                                loadUsageStats()
                            }
                        } message: {
                            Text("This will reset all API usage statistics. This action cannot be undone.")
                        }
                        
                        // Test Simulation Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Test Simulations")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                Button(action: {
                                    Task {
                                        await APIUsageTester.shared.simulateTypicalUsage()
                                        loadUsageStats()
                                    }
                                }) {
                                    Text("Simulate Typical Usage")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    Task {
                                        await APIUsageTester.shared.simulateFullDayUsage()
                                        loadUsageStats()
                                    }
                                }) {
                                    Text("Simulate Full Day")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.1))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    Task {
                                        await APIUsageTester.shared.simulateHeavyUsage()
                                        loadUsageStats()
                                    }
                                }) {
                                    Text("Simulate Heavy Usage")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange.opacity(0.1))
                                        .foregroundColor(.orange)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Text("Use these buttons to test different usage patterns and see how they affect your API usage statistics.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemPurple).opacity(0.1))
                        .cornerRadius(12)
                        
                    } else {
                        Text("Loading usage statistics...")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("API Usage")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadUsageStats()
            }
            .refreshable {
                loadUsageStats()
            }
        }
    }
    
    private func loadUsageStats() {
        usageStats = coinGeckoService.getUsageStatistics()
    }
}

#Preview {
    APIUsageDebugView()
} 