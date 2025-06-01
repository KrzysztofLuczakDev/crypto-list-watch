//
//  ContentView.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CryptoListViewModel()
    @State private var showingSearch = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else {
                    cryptoList
                }
            }
            .navigationTitle("Crypto")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                TextField("Search crypto...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.caption)
                    .onChange(of: viewModel.searchText) { _, _ in
                        viewModel.searchCryptocurrencies()
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: viewModel.clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var cryptoList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                let cryptosToShow = viewModel.searchText.isEmpty ? viewModel.cryptocurrencies : viewModel.searchResults
                
                if cryptosToShow.isEmpty && !viewModel.searchText.isEmpty {
                    emptySearchView
                } else {
                    ForEach(cryptosToShow) { crypto in
                        CryptocurrencyRowView(cryptocurrency: crypto)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 4)
        }
        .refreshable {
            viewModel.refresh()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                viewModel.refresh()
            }
            .font(.caption)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text("Try a different search term")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
