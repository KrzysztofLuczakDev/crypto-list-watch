# Crypto List - Apple Watch App

A cryptocurrency tracking app for Apple Watch that displays real-time cryptocurrency prices and market data.

## Features

### 📊 Top Cryptocurrencies

- View the top 10 cryptocurrencies by market cap
- Real-time price updates from CoinGecko API
- Market cap rankings and 24-hour price changes
- Color-coded price change indicators (green for gains, red for losses)

### ⭐ Favorites System

- **Star Button**: Tap the star icon next to any cryptocurrency to add it to your favorites
- **Favorites Tab**: Swipe to access your personalized favorites list
- **Persistent Storage**: Your favorite coins are saved locally and persist between app launches
- **Quick Access**: Easily toggle favorites on/off with a single tap

### 🔍 Search Functionality

- Search for any cryptocurrency by name or symbol
- Real-time search results with debounced API calls
- Clear search functionality

### 📱 Watch-Optimized UI

- Compact design optimized for Apple Watch screens
- Tab-based navigation between Top Coins and Favorites
- Pull-to-refresh functionality
- Loading states and error handling

## Technical Implementation

### Architecture

- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **SwiftUI**: Modern declarative UI framework
- **Async/Await**: Modern concurrency for API calls
- **UserDefaults**: Local persistence for favorites

### Key Components

- `FavoritesManager`: Handles favorite cryptocurrency persistence
- `CoinGeckoService`: API service for cryptocurrency data
- `CryptoListViewModel`: Main view model managing state and data
- `CryptocurrencyRowView`: Reusable row component with star button

### API Integration

- **CoinGecko API**: Free cryptocurrency data API
- **Endpoints Used**:
  - `/coins/markets` - Top cryptocurrencies and specific coin data
  - `/search` - Cryptocurrency search functionality

## Usage

1. **Browse Top Coins**: The app opens to show the top 10 cryptocurrencies
2. **Add Favorites**: Tap the star icon next to any coin to add it to favorites
3. **View Favorites**: Swipe right to access your favorites tab
4. **Search**: Use the search bar to find specific cryptocurrencies
5. **Refresh**: Pull down to refresh the data

## Requirements

- Apple Watch with watchOS 11.5 or later
- Internet connection for real-time data

## Installation

1. Open the project in Xcode
2. Select your Apple Watch as the target device
3. Build and run the app

## Future Enhancements

- Price alerts and notifications
- Portfolio tracking
- Historical price charts
- Additional market data (volume, supply, etc.)
- Customizable refresh intervals

## License

MIT License - feel free to use this project for learning and development.
