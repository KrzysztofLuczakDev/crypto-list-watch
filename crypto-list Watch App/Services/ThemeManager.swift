//
//  ThemeManager.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentColorScheme: ColorScheme?
    
    private let settingsManager = SettingsManager.shared
    
    private init() {
        updateColorScheme()
        
        // Listen for settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: .settingsDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func settingsDidChange() {
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        switch settingsManager.themeMode {
        case .light:
            currentColorScheme = .light
        case .dark:
            currentColorScheme = .dark
        case .system:
            currentColorScheme = nil // Let system decide
        }
    }
    
    /// Gets the appropriate color scheme based on user preference
    /// - Returns: ColorScheme or nil for system default
    func getColorScheme() -> ColorScheme? {
        return currentColorScheme
    }
    
    /// Applies the theme to a view
    /// - Parameter view: The view to apply the theme to
    /// - Returns: The view with the appropriate color scheme applied
    func applyTheme<Content: View>(to view: Content) -> some View {
        view.preferredColorScheme(currentColorScheme)
    }
}

// MARK: - View Extension for Easy Theme Application
extension View {
    
    /// Applies the current theme setting to the view
    /// - Returns: The view with the appropriate color scheme applied
    func applyAppTheme() -> some View {
        self.preferredColorScheme(ThemeManager.shared.getColorScheme())
    }
} 