//
//  ContentView.swift
//  Project2026
//
//  Main tab navigation for the app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }
            
            CleaningView()
                .tabItem {
                    Label("Cleaning", systemImage: "sparkles")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(themeService.currentTheme.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeService())
        .environmentObject(HabitService())
        .environmentObject(CleaningService())
        .environmentObject(WaterService())
        .environmentObject(ReadingService())
        .environmentObject(DaySummaryService())
}
