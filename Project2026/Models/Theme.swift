//
//  Theme.swift
//  Project2026
//
//  Theme model for app customization
//

import SwiftUI

struct AppTheme: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var primaryHex: String
    var accentHex: String
    var backgroundHex: String
    var cardHex: String
    var positiveHex: String
    var warningHex: String
    var isDark: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        primaryHex: String,
        accentHex: String,
        backgroundHex: String,
        cardHex: String,
        positiveHex: String,
        warningHex: String,
        isDark: Bool = false
    ) {
        self.id = id
        self.name = name
        self.primaryHex = primaryHex
        self.accentHex = accentHex
        self.backgroundHex = backgroundHex
        self.cardHex = cardHex
        self.positiveHex = positiveHex
        self.warningHex = warningHex
        self.isDark = isDark
    }
    
    // MARK: - Color Properties
    
    var primary: Color { Color(hex: primaryHex) }
    var accent: Color { Color(hex: accentHex) }
    var background: Color { Color(hex: backgroundHex) }
    var card: Color { Color(hex: cardHex) }
    var positive: Color { Color(hex: positiveHex) }
    var warning: Color { Color(hex: warningHex) }
    
    var colorScheme: ColorScheme? {
        isDark ? .dark : .light
    }
}

// MARK: - Default Themes

extension AppTheme {
    static let `default` = AppTheme(
        name: "Default",
        primaryHex: "#007AFF",
        accentHex: "#5856D6",
        backgroundHex: "#F2F2F7",
        cardHex: "#FFFFFF",
        positiveHex: "#34C759",
        warningHex: "#FF9500",
        isDark: false
    )
    
    static let minimal = AppTheme(
        name: "Minimal",
        primaryHex: "#1C1C1E",
        accentHex: "#8E8E93",
        backgroundHex: "#FFFFFF",
        cardHex: "#F2F2F7",
        positiveHex: "#34C759",
        warningHex: "#FF9500",
        isDark: false
    )
    
    static let outdoors = AppTheme(
        name: "Outdoors",
        primaryHex: "#2E7D32",
        accentHex: "#1565C0",
        backgroundHex: "#E8F5E9",
        cardHex: "#FFFFFF",
        positiveHex: "#43A047",
        warningHex: "#EF6C00",
        isDark: false
    )
    
    static let gym = AppTheme(
        name: "Gym",
        primaryHex: "#FF5722",
        accentHex: "#FF9800",
        backgroundHex: "#212121",
        cardHex: "#424242",
        positiveHex: "#4CAF50",
        warningHex: "#FFC107",
        isDark: true
    )
    
    static let allThemes: [AppTheme] = [.default, .minimal, .outdoors, .gym]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = components[0]
        let g = components.count > 1 ? components[1] : r
        let b = components.count > 2 ? components[2] : r
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
