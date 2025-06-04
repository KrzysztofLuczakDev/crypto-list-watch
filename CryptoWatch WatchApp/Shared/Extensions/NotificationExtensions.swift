//
//  NotificationExtensions.swift
//  CryptoWatch WatchApp
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import Foundation

// MARK: - Notification Extensions

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
    static let dataDidUpdate = Notification.Name("dataDidUpdate")
    static let networkStatusDidChange = Notification.Name("networkStatusDidChange")
} 