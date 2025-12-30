//
//  Project2026MacApp.swift
//  Project2026Mac
//
//  macOS companion app for Project 2026
//

import SwiftUI

@main
struct Project2026MacApp: App {
    @StateObject private var themeService = ThemeServiceMac()
    @StateObject private var habitService = HabitServiceMac()
    @StateObject private var cleaningService = CleaningServiceMac()
    @StateObject private var waterService = WaterServiceMac()
    @StateObject private var readingService = ReadingServiceMac()
    @StateObject private var daySummaryService = DaySummaryServiceMac()
    @StateObject private var workoutService = WorkoutServiceMac()
    
    var body: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(themeService)
                .environmentObject(habitService)
                .environmentObject(cleaningService)
                .environmentObject(waterService)
                .environmentObject(readingService)
                .environmentObject(daySummaryService)
                .environmentObject(workoutService)
                .preferredColorScheme(themeService.currentTheme.colorScheme)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 800)
        
        #if os(macOS)
        Settings {
            MacSettingsView()
                .environmentObject(themeService)
        }
        #endif
    }
}
