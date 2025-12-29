//
//  ThemeTests.swift
//  Project2026Tests
//
//  Tests for theme system
//

import XCTest
import SwiftUI
@testable import Project2026

final class ThemeTests: XCTestCase {
    
    // MARK: - Theme Color Tests
    
    func testDefaultThemePrimaryColor() {
        let theme = AppTheme.default
        
        XCTAssertNotNil(theme.primary)
        XCTAssertEqual(theme.name, "Default")
    }
    
    func testAllThemesExist() {
        let themes = AppTheme.allThemes
        
        XCTAssertGreaterThan(themes.count, 0, "Should have at least one theme")
        
        // Verify each theme has required properties
        for theme in themes {
            XCTAssertFalse(theme.name.isEmpty, "Theme name should not be empty")
            XCTAssertFalse(theme.primaryHex.isEmpty, "Theme primary hex should not be empty")
        }
    }
    
    func testHexColorConversion() {
        let color = Color(hex: "#FF5733")
        XCTAssertNotNil(color)
    }
    
    func testHexColorWithoutHash() {
        let color = Color(hex: "FF5733")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Theme Properties Tests
    
    func testThemeHasAllRequiredColors() {
        let theme = AppTheme.default
        
        XCTAssertNotNil(theme.primary)
        XCTAssertNotNil(theme.accent)
        XCTAssertNotNil(theme.background)
        XCTAssertNotNil(theme.card)
        XCTAssertNotNil(theme.positive)
        XCTAssertNotNil(theme.warning)
    }
    
    func testLightThemeColorScheme() {
        let theme = AppTheme(
            name: "Light Test",
            primaryHex: "#007AFF",
            accentHex: "#5856D6",
            backgroundHex: "#F2F2F7",
            cardHex: "#FFFFFF",
            positiveHex: "#34C759",
            warningHex: "#FF9500",
            isDark: false
        )
        
        XCTAssertEqual(theme.colorScheme, .light)
    }
    
    func testDarkThemeColorScheme() {
        let theme = AppTheme(
            name: "Dark Test",
            primaryHex: "#007AFF",
            accentHex: "#5856D6",
            backgroundHex: "#1C1C1E",
            cardHex: "#2C2C2E",
            positiveHex: "#30D158",
            warningHex: "#FF9F0A",
            isDark: true
        )
        
        XCTAssertEqual(theme.colorScheme, .dark)
    }
    
    // MARK: - Theme Equality Tests
    
    func testThemeEquality() {
        let theme1 = AppTheme.default
        let theme2 = AppTheme.default
        
        XCTAssertEqual(theme1.id, theme2.id)
    }
}
