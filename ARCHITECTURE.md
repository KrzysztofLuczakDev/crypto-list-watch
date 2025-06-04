# CryptoWatch WatchKit App - Architecture Documentation

## 📁 Project Structure Overview

The project has been reorganized following Apple's best practices and modern iOS/watchOS development patterns. The new structure promotes:

- **Separation of Concerns**: Clear boundaries between different layers
- **Scalability**: Easy to add new features and maintain existing ones
- **Testability**: Protocols and dependency injection for better testing
- **Reusability**: Shared components and utilities
- **Developer Experience**: Intuitive folder structure and naming conventions

## 🏗️ Architecture Pattern

The app follows a **MVVM (Model-View-ViewModel)** architecture with **Clean Architecture** principles:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      View       │───▶│      Model      │───▶│     Service     │
│   (SwiftUI)     │    │  (ObservableObject) │    │   (Protocol)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │    Manager      │    │   Repository    │
                       │   (Singleton)   │    │   (Protocol)    │
                       └─────────────────┘    └─────────────────┘
```

## 📂 Detailed Folder Structure

### `CryptoWatch WatchKit App/`

```
CryptoWatch WatchKit App/
├── App/                           # App entry point and configuration
│   └── CryptoWatchApp.swift      # Main app file with dependency injection
│
├── Core/                          # Core business logic and infrastructure
│   ├── Models/                    # Data models and entities
│   │   ├── Cryptocurrency.swift  # Main crypto model with computed properties
│   │   └── AppModels.swift       # Enums, states, and supporting models
│   │
│   ├── Services/                  # Business logic services
│   │   ├── CryptoDataService.swift        # Crypto data fetching and caching
│   │   └── CurrencyConversionService.swift # Currency conversion logic
│   │
│   ├── Managers/                  # State management and persistence
│   │   └── FavoritesManager.swift # Favorites persistence and management
│   │
│   ├── Networking/               # Network layer
│   │   ├── NetworkManager.swift  # Generic network manager
│   │   └── CryptoAPIEndpoints.swift # API endpoint definitions
│   │
│   └── Storage/                  # Data persistence (future: Core Data, etc.)
│
├── Features/                     # Feature-based organization
│   ├── CryptoList/              # Crypto list feature
│   │   ├── Models/              # Feature-specific models
│   │   │   └── CryptoListModel.swift # Main list data model
│   │   └── Views/               # Feature views
│   │       └── CryptoListView.swift # Main list view
│   │
│   ├── Favorites/               # Favorites feature
│   ├── Settings/                # Settings feature
│   └── Search/                  # Search feature
│
├── Shared/                      # Shared components and utilities
│   ├── Components/              # Reusable UI components
│   ├── Extensions/              # Swift extensions
│   │   └── CurrencyFormatter.swift # Currency formatting utilities
│   ├── Utils/                   # Utility functions and helpers
│   └── Constants/               # App-wide constants
│       └── AppConstants.swift   # Centralized constants
│
└── Resources/                   # App resources
    ├── Assets/                  # Asset catalogs
    └── Localization/           # Localization files
```

## 🔧 Key Architectural Components

### 1. **Dependency Injection**

The app uses dependency injection for better testability and flexibility:

```swift
// In CryptoWatchApp.swift
@StateObject private var settingsManager = SettingsManager.shared
@StateObject private var favoritesManager = FavoritesManager.shared
@StateObject private var currencyService = CurrencyConversionService.shared
```

### 2. **Protocol-Oriented Programming**

Services and managers use protocols for better testing and flexibility:

```swift
protocol CryptoDataServiceProtocol {
    func fetchTopCryptocurrencies(start: Int, limit: Int) async throws -> [Cryptocurrency]
    func fetchSpecificCryptocurrencies(ids: [String]) async throws -> [Cryptocurrency]
}

protocol FavoritesManagerProtocol: ObservableObject {
    var favoriteIds: Set<String> { get }
    func toggleFavorite(_ cryptocurrency: Cryptocurrency)
}
```

### 3. **Feature-Based Organization**

Each major feature has its own folder with related components:

- **Models**: Handle business logic and state management
- **Views**: SwiftUI views specific to the feature
- **Supporting Files**: Feature-specific models if needed

### 4. **Centralized Configuration**

All app constants are centralized in `AppConstants.swift`:

```swift
enum AppConstants {
    enum API {
        static let defaultPageSize = 50
        static let requestTimeout: TimeInterval = 15
    }

    enum Cache {
        static let cryptoDataExpiration: TimeInterval = 60
    }
}
```

## 🔄 Data Flow

### 1. **Network Requests**

```
View → Model → Service → NetworkManager → API
```

### 2. **State Management**

```
Manager (ObservableObject) → Model → View (UI Update)
```

### 3. **Caching Strategy**

```
Service → Cache Check → Network Request (if needed) → Cache Update
```

## 🧪 Testing Strategy

The new architecture supports comprehensive testing:

### 1. **Unit Tests**

- **Services**: Test business logic with mock network managers
- **Models**: Test state management with mock services
- **Managers**: Test persistence and state changes

### 2. **Mock Objects**

```swift
final class MockCryptoDataService: CryptoDataServiceProtocol {
    var shouldFail = false
    var mockData: [Cryptocurrency] = []

    func fetchTopCryptocurrencies(start: Int, limit: Int) async throws -> [Cryptocurrency] {
        if shouldFail { throw AppError.networkError("Mock error") }
        return Array(mockData.prefix(limit))
    }
}
```

### 3. **Integration Tests**

- Test complete data flow from network to UI
- Test error handling and edge cases

## 🚀 Benefits of New Structure

### 1. **Maintainability**

- Clear separation of concerns
- Easy to locate and modify specific functionality
- Consistent naming conventions

### 2. **Scalability**

- Easy to add new features without affecting existing code
- Modular architecture supports team development
- Feature flags and A/B testing support

### 3. **Testability**

- Protocol-based design enables easy mocking
- Dependency injection supports isolated testing
- Clear boundaries between layers

### 4. **Performance**

- Efficient caching strategies
- Lazy loading and pagination support
- Memory management best practices

### 5. **Developer Experience**

- Intuitive folder structure
- Comprehensive documentation
- Type-safe constants and configurations

## 📋 Migration Guide

### From Old Structure to New Structure:

1. **Move Models**: `Models/` → `Core/Models/`
2. **Reorganize Services**: `Services/` → `Core/Services/` and `Core/Managers/`
3. **Create Features**: Group related Models and Views in `Features/`
4. **Centralize Constants**: Move all constants to `Shared/Constants/`
5. **Update Imports**: Update import statements to reflect new structure

### Breaking Changes:

- File paths have changed
- Some classes may have been renamed for consistency
- Import statements need to be updated

## 🔮 Future Enhancements

### 1. **Core Data Integration**

- Add `Core/Storage/CoreDataManager.swift`
- Implement offline data persistence

### 2. **Widget Support**

- Add `Features/Widget/` for widget-specific code
- Share models and services with main app

### 3. **Localization**

- Add `Resources/Localization/` files
- Implement multi-language support

### 4. **Analytics**

- Add `Core/Analytics/` for tracking
- Implement privacy-focused analytics

## 📚 Best Practices

### 1. **File Organization**

- Keep files focused on single responsibility
- Use clear, descriptive naming
- Group related functionality together

### 2. **Code Style**

- Use MARK comments for organization
- Follow Swift naming conventions
- Document public APIs

### 3. **Error Handling**

- Use typed errors (`AppError` enum)
- Provide meaningful error messages
- Handle edge cases gracefully

### 4. **Performance**

- Use `@MainActor` for UI updates
- Implement proper caching strategies
- Optimize network requests

This architecture provides a solid foundation for building a maintainable, scalable, and testable watchOS application while following Apple's best practices and modern iOS development patterns.
