//
//  ThemeService.swift
//  Project2026
//
//  Service for managing app themes
//

import SwiftUI

/// Manages the app's visual theme with persistence across sessions.
/// Provides available theme options and handles theme switching with automatic
/// UserDefaults storage. Injected via @EnvironmentObject throughout the app.
@MainActor
public class ThemeService: ObservableObject {
    @Published public var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    @Published public var availableThemes: [AppTheme]
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    public init() {
        self.availableThemes = AppTheme.allThemes
        
        // Load saved theme or use default
        if let data = userDefaults.data(forKey: themeKey),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .default
        }
    }
    
    public func selectTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    public func resetToDefault() {
        currentTheme = .default
    }
    
    private func saveTheme() {
        if let data = try? JSONEncoder().encode(currentTheme) {
            userDefaults.set(data, forKey: themeKey)
        }
    }
}

// MARK: - Theme Environment Key

public struct ThemeEnvironmentKey: EnvironmentKey {
    public static let defaultValue: AppTheme = .default
}

extension EnvironmentValues {
    public var theme: AppTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Modifier for Theme

public struct ThemedViewModifier: ViewModifier {
    @EnvironmentObject var themeService: ThemeService
    
    public func body(content: Content) -> some View {
        content
            .environment(\.theme, themeService.currentTheme)
    }
}

extension View {
    public func themed() -> some View {
        modifier(ThemedViewModifier())
    }
}
