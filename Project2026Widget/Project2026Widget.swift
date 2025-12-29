//
//  Project2026Widget.swift
//  Project2026Widget
//
//  Home screen widget for Project 2026
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct Project2026Entry: TimelineEntry {
    let date: Date
    let score: Double
    let habitsCompleted: Int
    let habitsTotal: Int
    let waterProgress: Double
    let waterCurrent: Int
    let waterTarget: Int
    let nextCleaningTask: String?
    let didReadToday: Bool
}

// MARK: - Timeline Provider

struct Project2026Provider: TimelineProvider {
    func placeholder(in context: Context) -> Project2026Entry {
        Project2026Entry(
            date: Date(),
            score: 75,
            habitsCompleted: 8,
            habitsTotal: 12,
            waterProgress: 0.6,
            waterCurrent: 60,
            waterTarget: 100,
            nextCleaningTask: "Kitchen reset",
            didReadToday: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Project2026Entry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Project2026Entry>) -> Void) {
        let entry = loadEntry()
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadEntry() -> Project2026Entry {
        // Load from shared UserDefaults (App Group)
        let defaults = UserDefaults(suiteName: "group.com.project2026.app")
        
        let score = defaults?.double(forKey: "widget_score") ?? 0
        let habitsCompleted = defaults?.integer(forKey: "widget_habits_completed") ?? 0
        let habitsTotal = defaults?.integer(forKey: "widget_habits_total") ?? 0
        let waterCurrent = defaults?.integer(forKey: "widget_water_current") ?? 0
        let waterTarget = defaults?.integer(forKey: "widget_water_target") ?? 100
        let nextTask = defaults?.string(forKey: "widget_next_cleaning")
        let didRead = defaults?.bool(forKey: "widget_did_read") ?? false
        
        let waterProgress = waterTarget > 0 ? Double(waterCurrent) / Double(waterTarget) : 0
        
        return Project2026Entry(
            date: Date(),
            score: score,
            habitsCompleted: habitsCompleted,
            habitsTotal: habitsTotal,
            waterProgress: waterProgress,
            waterCurrent: waterCurrent,
            waterTarget: waterTarget,
            nextCleaningTask: nextTask,
            didReadToday: didRead
        )
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: Project2026Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Title
            Text("Project 2026")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // Score Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                
                Circle()
                    .trim(from: 0, to: entry.score / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(Int(entry.score))")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 60, height: 60)
            
            // Habits Count
            Text("\(entry.habitsCompleted)/\(entry.habitsTotal)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    private var scoreColor: Color {
        if entry.score >= 80 { return .green }
        if entry.score >= 50 { return .orange }
        return .red
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: Project2026Entry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Score
            VStack(spacing: 8) {
                Text("Project 2026")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: entry.score / 100)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(Int(entry.score))")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 70, height: 70)
            }
            .frame(width: 90)
            
            // Right: Details
            VStack(alignment: .leading, spacing: 8) {
                // Habits
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Habits")
                        .font(.caption)
                    Spacer()
                    Text("\(entry.habitsCompleted)/\(entry.habitsTotal)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Water
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    Text("Water")
                        .font(.caption)
                    Spacer()
                    Text("\(entry.waterCurrent)/\(entry.waterTarget)oz")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Reading
                HStack {
                    Image(systemName: entry.didReadToday ? "book.fill" : "book")
                        .foregroundColor(.orange)
                    Text("Reading")
                        .font(.caption)
                    Spacer()
                    Text(entry.didReadToday ? "✓" : "—")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Cleaning
                if let task = entry.nextCleaningTask {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text(task)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    private var scoreColor: Color {
        if entry.score >= 80 { return .green }
        if entry.score >= 50 { return .orange }
        return .red
    }
}

// MARK: - Widget Configuration

struct Project2026Widget: Widget {
    let kind: String = "Project2026Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Project2026Provider()) { entry in
            Project2026WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Project 2026")
        .description("Track your daily progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Entry View

struct Project2026WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: Project2026Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct Project2026WidgetBundle: WidgetBundle {
    var body: some Widget {
        Project2026Widget()
    }
}

// MARK: - Previews

#Preview("Small Widget", as: .systemSmall) {
    Project2026Widget()
} timeline: {
    Project2026Entry(
        date: Date(),
        score: 75,
        habitsCompleted: 8,
        habitsTotal: 12,
        waterProgress: 0.6,
        waterCurrent: 60,
        waterTarget: 100,
        nextCleaningTask: "Kitchen reset",
        didReadToday: true
    )
}

#Preview("Medium Widget", as: .systemMedium) {
    Project2026Widget()
} timeline: {
    Project2026Entry(
        date: Date(),
        score: 85,
        habitsCompleted: 10,
        habitsTotal: 12,
        waterProgress: 0.8,
        waterCurrent: 80,
        waterTarget: 100,
        nextCleaningTask: "Bathroom",
        didReadToday: true
    )
}
