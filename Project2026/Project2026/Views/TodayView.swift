import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var showingAddWater = false
    @State private var showingLogReading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Card
                    if let summary = viewModel.todaysSummary {
                        SummaryCard(summary: summary)
                    }
                    
                    // Water Tracker
                    WaterTrackerCard(
                        progress: viewModel.waterProgress,
                        amount: viewModel.waterAmount,
                        onAddWater: { ounces in
                            viewModel.addWater(ounces)
                        }
                    )
                    
                    // Reading Progress
                    if !viewModel.currentBooks.isEmpty {
                        ReadingProgressCard(books: viewModel.currentBooks) {
                            showingLogReading = true
                        }
                    }
                    
                    // Active Habits
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Habits")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.activeHabits) { habit in
                            HabitRow(
                                habit: habit,
                                isCompleted: viewModel.habitLogs.contains { $0.habitId == habit.id && $0.completed }
                            ) {
                                viewModel.toggleHabit(habit)
                            }
                        }
                    }
                    
                    // Cleaning Tasks
                    if !viewModel.cleaningTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Cleaning")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.cleaningTasks) { task in
                                CleaningTaskRow(task: task) {
                                    viewModel.completeCleaningTask(task)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Project 2026")
            .onAppear {
                viewModel.refreshData()
            }
        }
    }
}

struct SummaryCard: View {
    let summary: DaySummary
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Daily Score")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: summary.score / 100)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(summary.score))%")
                    .font(.title)
                    .bold()
            }
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(summary.habitsCompleted)/\(summary.habitsTotal)")
                        .font(.caption)
                    Text("Habits")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(summary.cleaningCompleted)/\(summary.cleaningTotal)")
                        .font(.caption)
                    Text("Cleaning")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(summary.waterConsumed)oz")
                        .font(.caption)
                    Text("Water")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct HabitRow: View {
    let habit: HabitTemplate
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading) {
                    Text(habit.title)
                        .foregroundColor(.primary)
                    Text(habit.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

struct CleaningTaskRow: View {
    let task: CleaningTask
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.body)
                if let minutes = task.estimatedMinutes {
                    Text("~\(minutes) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if task.isOverdue {
                Text("Overdue")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Button(action: onComplete) {
                Image(systemName: "checkmark.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    TodayView()
}
