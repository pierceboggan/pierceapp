import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "checkmark.circle")
                }
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "list.bullet")
                }
            
            CleaningView()
                .tabItem {
                    Label("Cleaning", systemImage: "sparkles")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
