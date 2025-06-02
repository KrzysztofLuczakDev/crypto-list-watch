# Crypto List - Apple Watch App

A sleek and intuitive cryptocurrency tracking app designed specifically for Apple Watch. Monitor your favorite cryptocurrencies with real-time price updates, market data, and customizable watchlists.

## Features

- **Real-time Price Updates**: Live cryptocurrency prices and market data
- Real-time price updates from CoinLore API (completely free)
- **Favorites/Watchlist**: Add and manage your favorite cryptocurrencies
- **Multiple Currency Support**: View prices in 30+ fiat currencies and 6 cryptocurrencies
- **Dark Mode Interface**: Optimized for Apple Watch with dark theme
- **Smart Refresh**: Intelligent data caching to minimize API calls
- **Search Functionality**: Find cryptocurrencies by name or symbol
- **Pagination Support**: Browse through thousands of cryptocurrencies
- **Auto-refresh**: Configurable automatic data updates

## Architecture

### Core Components

- **CoinLoreService**: API service for cryptocurrency data from CoinLore
- **CurrencyConversionService**: Free currency conversion using fawazahmed0/currency-api
- **FavoritesManager**: Manages user's favorite cryptocurrencies using nameids
- **SettingsManager**: Handles app preferences and configuration
- **CryptoListViewModel**: Main view model with smart refresh logic

### APIs Used

- **CoinLore API**: Free cryptocurrency data API with no rate limits
- **fawazahmed0/currency-api**: Completely free currency conversion API

## Technical Details

### Smart Refresh System

- Data is cached for 30 seconds to avoid unnecessary API calls
- Tab switching only refreshes if data is stale
- Force refresh available via pull-to-refresh gesture
- Auto-refresh timer uses smart refresh to minimize network usage

### Currency Support

- 30+ fiat currencies supported
- 6 major cryptocurrencies as base currencies
- Real-time currency conversion from USD base prices
- Exchange rates cached for optimal performance

### Favorites System

- Uses cryptocurrency `nameid` for reliable identification
- Automatic migration from old ID-based system
- Smart detection of favorites list changes
- Persistent storage across app launches

## Installation

1. Clone the repository
2. Open `crypto-list.xcodeproj` in Xcode
3. Select your Apple Watch as the target device
4. Build and run the project

## Requirements

- Xcode 15.0+
- watchOS 10.0+
- Apple Watch Series 4 or later

## API Information

This app uses completely free APIs:

- **CoinLore**: Unlimited free cryptocurrency data
- **fawazahmed0/currency-api**: Unlimited free currency conversion

No API keys required, perfect for commercial use without restrictions.
