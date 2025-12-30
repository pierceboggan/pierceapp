import SwiftUI

public struct ContentView: View {
    @EnvironmentObject var themeService: ThemeService
    
    public var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
            
            FitnessView()
                .tabItem {
                    Label("Fitness", systemImage: "figure.run")
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
    
    public init() {}
}
