import SwiftUI

/// Main content view for tvOS with tab-based navigation.
/// Prioritizes Mobility as the primary feature for TV viewing.
struct TVContentView: View {
    @Environment(TVMobilityService.self) private var mobilityService
    @Environment(TVStatsService.self) private var statsService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TVMobilityHomeView()
                .tabItem {
                    Label("Mobility", systemImage: "figure.flexibility")
                }
                .tag(0)
            
            TVStatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            TVSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

/// Home view for mobility routines on tvOS.
struct TVMobilityHomeView: View {
    @Environment(TVMobilityService.self) private var mobilityService
    @State private var showingRoutine = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 60) {
                // Hero section
                VStack(spacing: 20) {
                    Image(systemName: "figure.flexibility")
                        .font(.system(size: 120))
                        .foregroundStyle(.blue)
                    
                    Text("Mobility Routine")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("10-minute daily stretch routine")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                // Stats preview
                HStack(spacing: 80) {
                    StatCard(title: "Today", value: mobilityService.todayMinutes, unit: "min")
                    StatCard(title: "Streak", value: mobilityService.currentStreak, unit: "days")
                    StatCard(title: "Total", value: mobilityService.totalSessions, unit: "sessions")
                }
                
                // Start button
                Button {
                    showingRoutine = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "play.fill")
                            .font(.title)
                        Text("Start Routine")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 60)
                    .padding(.vertical, 20)
                }
                .buttonStyle(.borderedProminent)
                
                // Exercise preview
                VStack(alignment: .leading, spacing: 20) {
                    Text("Exercises")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(TVMobilityRoutine.bikeRoutine.exercises) { exercise in
                                ExercisePreviewCard(exercise: exercise)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(60)
            .fullScreenCover(isPresented: $showingRoutine) {
                TVMobilityRoutineView()
            }
        }
    }
}

/// Card showing a stat value with title and unit.
struct StatCard: View {
    let title: String
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.system(size: 56, weight: .bold))
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 200)
        .padding(.vertical, 30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

/// Preview card for an exercise in the routine.
struct ExercisePreviewCard: View {
    let exercise: TVMobilityExercise
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: exercise.iconName)
                .font(.system(size: 40))
                .foregroundStyle(.blue)
            
            Text(exercise.name)
                .font(.callout)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("\(exercise.durationSeconds)s")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 180, height: 150)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

/// Stats view showing mobility history.
struct TVStatsView: View {
    @Environment(TVStatsService.self) private var statsService
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Your Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack(spacing: 60) {
                    StatCard(title: "This Week", value: statsService.weeklyMinutes, unit: "minutes")
                    StatCard(title: "This Month", value: statsService.monthlyMinutes, unit: "minutes")
                    StatCard(title: "All Time", value: statsService.totalMinutes, unit: "minutes")
                }
                
                // Weekly chart placeholder
                VStack(alignment: .leading, spacing: 20) {
                    Text("This Week")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(statsService.weeklyData, id: \.day) { data in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue.opacity(0.7))
                                    .frame(width: 60, height: CGFloat(data.minutes * 10))
                                Text(data.day)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(60)
        }
    }
}

/// Settings view for tvOS app.
struct TVSettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                Section("Audio") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                }
                
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    TVContentView()
        .environment(TVMobilityService())
        .environment(TVStatsService())
}
