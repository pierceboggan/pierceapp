//
//  CleaningSheets.swift
//  Project2026
//
//  Sheets for cleaning task management
//

import SwiftUI

// MARK: - Add Cleaning Task Sheet

public struct AddCleaningTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String = ""
    @State private var area: String = "Main Level"
    @State private var recurrence: CleaningRecurrence = .weekly
    @State private var customDays: String = "7"
    @State private var estimatedMinutes: String = ""
    
    private var theme: AppTheme { themeService.currentTheme }
    
    /// Common areas for cleaning tasks.
    private let commonAreas = [
        "Main Level",
        "Kitchen",
        "Living Room",
        "Dining Room",
        "Bathrooms",
        "Basement",
        "Downstairs",
        "Bedroom",
        "Garage",
        "Office"
    ]
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Task name", text: $title)
                    
                    Picker("Area", selection: $area) {
                        ForEach(commonAreas, id: \.self) { areaOption in
                            Text(areaOption).tag(areaOption)
                        }
                    }
                    
                    HStack {
                        Text("Estimated time")
                        Spacer()
                        TextField("0", text: $estimatedMinutes)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Recurrence") {
                    Picker("Frequency", selection: $recurrence) {
                        Text("Daily").tag(CleaningRecurrence.daily)
                        Text("Weekly").tag(CleaningRecurrence.weekly)
                        Text("Every 2 weeks").tag(CleaningRecurrence.biweekly)
                        Text("Monthly").tag(CleaningRecurrence.monthly)
                        Text("Custom").tag(CleaningRecurrence.custom(days: 7))
                    }
                    
                    if case .custom = recurrence {
                        HStack {
                            Text("Every")
                            TextField("7", text: $customDays)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            Text("days")
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTask()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var finalRecurrence: CleaningRecurrence {
        if case .custom = recurrence {
            return .custom(days: Int(customDays) ?? 7)
        }
        return recurrence
    }
    
    private func addTask() {
        let task = CleaningTask(
            title: title.trimmingCharacters(in: .whitespaces),
            area: area,
            recurrence: finalRecurrence,
            estimatedMinutes: Int(estimatedMinutes)
        )
        
        Task {
            await cleaningService.addTask(task)
            dismiss()
        }
    }
}

// MARK: - Edit Cleaning Task Sheet

public struct EditCleaningTaskSheet: View {
    let task: CleaningTask
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String = ""
    @State private var area: String = "Main Level"
    @State private var recurrence: CleaningRecurrence = .weekly
    @State private var customDays: String = "7"
    @State private var estimatedMinutes: String = ""
    @State private var isActive: Bool = true
    @State private var showingDeleteConfirmation = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    /// Common areas for cleaning tasks.
    private let commonAreas = [
        "Main Level",
        "Kitchen",
        "Living Room",
        "Dining Room",
        "Bathrooms",
        "Basement",
        "Downstairs",
        "Bedroom",
        "Garage",
        "Office"
    ]
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Task name", text: $title)
                    
                    Picker("Area", selection: $area) {
                        ForEach(commonAreas, id: \.self) { areaOption in
                            Text(areaOption).tag(areaOption)
                        }
                    }
                    
                    HStack {
                        Text("Estimated time")
                        Spacer()
                        TextField("0", text: $estimatedMinutes)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Recurrence") {
                    Picker("Frequency", selection: $recurrence) {
                        Text("Daily").tag(CleaningRecurrence.daily)
                        Text("Weekly").tag(CleaningRecurrence.weekly)
                        Text("Every 2 weeks").tag(CleaningRecurrence.biweekly)
                        Text("Monthly").tag(CleaningRecurrence.monthly)
                        Text("Custom").tag(CleaningRecurrence.custom(days: 7))
                    }
                    
                    if case .custom = recurrence {
                        HStack {
                            Text("Every")
                            TextField("7", text: $customDays)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            Text("days")
                        }
                    }
                }
                
                Section {
                    Toggle("Active", isOn: $isActive)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadTask()
            }
            .alert("Delete Task", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        await cleaningService.deleteTask(task)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this task? This action cannot be undone.")
            }
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func loadTask() {
        title = task.title
        area = task.area
        recurrence = task.recurrence
        if case .custom(let days) = task.recurrence {
            customDays = String(days)
        }
        if let minutes = task.estimatedMinutes {
            estimatedMinutes = String(minutes)
        }
        isActive = task.isActive
    }
    
    private var finalRecurrence: CleaningRecurrence {
        if case .custom = recurrence {
            return .custom(days: Int(customDays) ?? 7)
        }
        return recurrence
    }
    
    private func saveTask() {
        var updatedTask = task
        updatedTask.title = title.trimmingCharacters(in: .whitespaces)
        updatedTask.area = area
        updatedTask.recurrence = finalRecurrence
        updatedTask.estimatedMinutes = Int(estimatedMinutes)
        updatedTask.isActive = isActive
        updatedTask.updatedAt = Date()
        
        Task {
            await cleaningService.updateTask(updatedTask)
            dismiss()
        }
    }
}

// MARK: - Complete Cleaning Task Sheet

public struct CompleteCleaningTaskSheet: View {
    let task: CleaningTask
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cleaningService: CleaningService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var durationMinutes: String = ""
    @State private var note: String = ""
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(.purple)
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.recurrence.displayText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Duration (Optional)") {
                    HStack {
                        Text("Time spent")
                        Spacer()
                        TextField(task.estimatedMinutes.map { String($0) } ?? "0", text: $durationMinutes)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Note (Optional)") {
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Complete Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        completeTask()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func completeTask() {
        Task {
            await cleaningService.completeTask(
                task,
                durationMinutes: Int(durationMinutes),
                note: note.isEmpty ? nil : note
            )
            dismiss()
        }
    }
}

#Preview {
    AddCleaningTaskSheet()
        .environmentObject(CleaningService())
        .environmentObject(ThemeService())
}
