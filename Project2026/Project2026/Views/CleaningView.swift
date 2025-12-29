import SwiftUI

struct CleaningView: View {
    @StateObject private var viewModel = CleaningViewModel()
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today's Tasks")) {
                    ForEach(viewModel.todaysTasks) { task in
                        CleaningTaskListRow(task: task) {
                            viewModel.completeTask(task)
                        }
                    }
                }
                
                Section(header: Text("All Tasks")) {
                    ForEach(viewModel.tasks) { task in
                        CleaningTaskDetailRow(task: task)
                    }
                }
            }
            .navigationTitle("Cleaning")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddCleaningTaskView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadTasks()
            }
        }
    }
}

struct CleaningTaskListRow: View {
    let task: CleaningTask
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.body)
                HStack {
                    Text(task.recurrence.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let minutes = task.estimatedMinutes {
                        Text("• \(minutes) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if task.isOverdue {
                Text("Overdue")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: onComplete) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

struct CleaningTaskDetailRow: View {
    let task: CleaningTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(task.title)
                    .font(.body)
                Spacer()
                if !task.isActive {
                    Text("Inactive")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(task.recurrence.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let minutes = task.estimatedMinutes {
                    Text("• \(minutes) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Next: \(task.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AddCleaningTaskView: View {
    @ObservedObject var viewModel: CleaningViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var recurrence: CleaningRecurrence = .weekly
    @State private var estimatedMinutes = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Task Name", text: $title)
                
                Picker("Recurrence", selection: $recurrence) {
                    Text("Daily").tag(CleaningRecurrence.daily)
                    Text("Weekly").tag(CleaningRecurrence.weekly)
                    Text("Monthly").tag(CleaningRecurrence.monthly)
                    Text("Custom").tag(CleaningRecurrence.custom)
                }
                
                TextField("Estimated Minutes (optional)", text: $estimatedMinutes)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Cleaning Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let minutes = Int(estimatedMinutes)
                        viewModel.addTask(title: title, recurrence: recurrence, estimatedMinutes: minutes)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CleaningView()
}
