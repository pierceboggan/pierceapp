import Foundation
import SwiftUI

class ThemeService: ObservableObject {
    @Published var currentTheme: Theme
    
    private let themeKey = "currentTheme"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: themeKey),
           let decoded = try? JSONDecoder().decode(Theme.self, from: data) {
            currentTheme = decoded
        } else {
            currentTheme = Theme.defaultTheme
        }
    }
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
        saveTheme()
    }
    
    private func saveTheme() {
        if let encoded = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(encoded, forKey: themeKey)
        }
    }
}
