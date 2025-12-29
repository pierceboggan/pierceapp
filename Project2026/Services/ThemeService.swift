//
//  ThemeService.swift
//  Project2026
//
//  Service for managing app themes
//

import SwiftUI

@MainActor
class ThemeService: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    @Published var availableThemes: [AppTheme]
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    init() {
        self.availableThemes = AppTheme.allThemes
        
        // Load saved theme or use default
        if let data = userDefaults.data(forKey: themeKey),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .default
        }
    }
    
    func selectTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    func resetToDefault() {
        currentTheme = .default
    }
    
    private func saveTheme() {
        if let data = try? JSONEncoder().encode(currentTheme) {
            userDefaults.set(data, forKey: themeKey)
        }
    }
}

// MARK: - Theme Environment Key

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppTheme = .default
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Modifier for Theme

struct ThemedViewModifier: ViewModifier {
    @EnvironmentObject var themeService: ThemeService
    
    func body(content: Content) -> some View {
        content
            .environment(\.theme, themeService.currentTheme)
    }
}

extension View {
    func themed() -> some View {
        modifier(ThemedViewModifier())
    }
}
