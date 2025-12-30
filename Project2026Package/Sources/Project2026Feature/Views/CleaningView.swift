//
//  CleaningView.swift
//  Project2026
//
//  View for managing cleaning tasks and rotation
//

import SwiftUI

public struct CleaningView: View {
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var showingAddTask = false
    @State private var selectedSegment = 0
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment Control
                Picker("View", selection: $selectedSegment) {
                    Text("Today").tag(0)
                    Text("All Tasks").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedSegment == 0 {
                    TodayCleaningView()
                } else if selectedSegment == 1 {
                    AllTasksView()
                } else {
                    CleaningHistoryView()
                }
            }
            .background(theme.background)
            .navigationTitle("Cleaning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddCleaningTaskSheet()
            }
        }
    }
}

// MARK: - Today Cleaning View

public struct TodayCleaningView: View {
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    private var todayTasks: [CleaningTask] { cleaningService.tasksForToday() }
    private var overdueTasks: [CleaningTask] { cleaningService.overdueTasks }
    
    /// Returns unique areas from today's tasks in order.
    private var areas: [String] {
        var seen = Set<String>()
        return todayTasks.compactMap { task in
            if seen.contains(task.area) { return nil }
            seen.insert(task.area)
            return task.area
        }
    }
    
    /// Returns unique areas from overdue tasks in order.
    private var overdueAreas: [String] {
        var seen = Set<String>()
        return overdueTasks.compactMap { task in
            if seen.contains(task.area) { return nil }
            seen.insert(task.area)
            return task.area
        }
    }
    
    public var body: some View {
        List {
            // Progress Card
            Section {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Today's Progress")
                                .font(.headline)
                            Text("\(completedCount) of \(todayTasks.count) tasks")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.purple.opacity(0.2), lineWidth: 8)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(Color.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Overdue Tasks (grouped by area)
            if !overdueTasks.isEmpty {
                ForEach(overdueAreas, id: \.self) { area in
                    Section {
                        ForEach(overdueTasks.filter { $0.area == area }) { task in
                            CleaningTaskRow(task: task)
                        }
                    } header: {
                        HStack {
                            Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(area)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Today's Tasks (grouped by area)
            if !todayTasks.isEmpty {
                ForEach(areas, id: \.self) { area in
                    Section(area) {
                        ForEach(todayTasks.filter { $0.area == area }) { task in
                            CleaningTaskRow(task: task)
                        }
                    }
                }
            }
            
            if todayTasks.isEmpty && overdueTasks.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundColor(.purple)
                        Text("All caught up!")
                            .font(.headline)
                        Text("No cleaning tasks due today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var completedCount: Int {
        todayTasks.filter { cleaningService.isTaskCompleted($0, on: Date()) }.count
    }
    
    private var progress: Double {
        guard !todayTasks.isEmpty else { return 1.0 }
        return Double(completedCount) / Double(todayTasks.count)
    }
}

// MARK: - All Tasks View

public struct AllTasksView: View {
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var showArchived = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    /// Returns unique areas from active tasks in order.
    private var areas: [String] {
        var seen = Set<String>()
        return cleaningService.activeTasks.compactMap { task in
            if seen.contains(task.area) { return nil }
            seen.insert(task.area)
            return task.area
        }
    }
    
    public var body: some View {
        List {
            // Active Tasks grouped by area
            ForEach(areas, id: \.self) { area in
                let tasks = cleaningService.activeTasks.filter { $0.area == area }
                if !tasks.isEmpty {
                    Section(area) {
                        ForEach(tasks) { task in
                            AllTasksRow(task: task)
                        }
                    }
                }
            }
            
            // Archived
            if showArchived {
                let archived = cleaningService.archivedTasks
                if !archived.isEmpty {
                    Section("Archived") {
                        ForEach(archived) { task in
                            AllTasksRow(task: task, isArchived: true)
                        }
                    }
                }
            }
            
            Section {
                Button {
                    showArchived.toggle()
                } label: {
                    Label(
                        showArchived ? "Hide Archived" : "Show Archived",
                        systemImage: showArchived ? "eye.slash" : "eye"
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Cleaning History View

public struct CleaningHistoryView: View {
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        List {
            ForEach(recentLogs, id: \.id) { log in
                if let task = cleaningService.tasks.first(where: { $0.id == log.taskId }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.subheadline)
                            Text(formatDate(log.completedDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let duration = log.durationMinutes {
                            Label("\(duration) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if recentLogs.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No cleaning history yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var recentLogs: [CleaningLog] {
        cleaningService.logs
            .sorted { $0.completedDate > $1.completedDate }
            .prefix(50)
            .map { $0 }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Cleaning Task Row

public struct CleaningTaskRow: View {
    let task: CleaningTask
    
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    @State private var showingComplete = false
    
    private var theme: AppTheme { themeService.currentTheme }
    private var isCompleted: Bool { cleaningService.isTaskCompleted(task, on: Date()) }
    
    public var body: some View {
        HStack {
            Button {
                if !isCompleted {
                    showingComplete = true
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? theme.positive : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    Text(task.recurrence.displayText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let minutes = task.estimatedMinutes {
                        Label("\(minutes) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if task.isOverdue && !isCompleted {
                        Text("Overdue")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            if !isCompleted {
                Menu {
                    Button {
                        showingComplete = true
                    } label: {
                        Label("Complete", systemImage: "checkmark.circle")
                    }
                    
                    Button {
                        Task {
                            await cleaningService.snoozeTaskForOneDay(task)
                        }
                    } label: {
                        Label("Snooze 1 day", systemImage: "moon")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingComplete) {
            CompleteCleaningTaskSheet(task: task)
        }
    }
}

// MARK: - All Tasks Row

public struct AllTasksRow: View {
    let task: CleaningTask
    public var isArchived: Bool = false
    
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    @State private var showingEdit = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .foregroundColor(isArchived ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    Text(task.recurrence.displayText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let minutes = task.estimatedMinutes {
                        Label("\(minutes) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let dueIn = task.daysUntilDue {
                        if dueIn < 0 {
                            Text("\(abs(dueIn)) days overdue")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if dueIn == 0 {
                            Text("Due today")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else {
                            Text("Due in \(dueIn) days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                showingEdit = true
            } label: {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showingEdit) {
            EditCleaningTaskSheet(task: task)
        }
    }
}

// MARK: - Preview

#Preview {
    CleaningView()
        .environmentObject(CleaningService())
        .environmentObject(ThemeService())
}
