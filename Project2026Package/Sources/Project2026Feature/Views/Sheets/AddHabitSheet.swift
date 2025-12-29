//
//  AddHabitSheet.swift
//  Project2026
//
//  Sheet for adding a new custom habit
//

import SwiftUI

public struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String = ""
    @State private var category: HabitCategory = .custom
    @State private var inputType: HabitInputType = .boolean
    @State private var frequencyType: FrequencyType = .daily
    @State private var daysPerWeek: Int = 3
    @State private var selectedDays: Set<Int> = []
    @State private var targetValue: String = ""
    @State private var unit: String = ""
    
    enum FrequencyType: String, CaseIterable {
        case daily = "Daily"
        case weekly = "X days/week"
        case specificDays = "Specific days"
    }
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $title)
                    
                    Picker("Category", selection: $category) {
                        ForEach(HabitCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
                
                Section("Frequency") {
                    Picker("Frequency", selection: $frequencyType) {
                        ForEach(FrequencyType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if frequencyType == .weekly {
                        Stepper("Days per week: \(daysPerWeek)", value: $daysPerWeek, in: 1...7)
                    }
                    
                    if frequencyType == .specificDays {
                        DaySelector(selectedDays: $selectedDays)
                    }
                }
                
                Section("Tracking Type") {
                    Picker("Input Type", selection: $inputType) {
                        ForEach(HabitInputType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if inputType == .numeric || inputType == .duration {
                        HStack {
                            Text("Target")
                            Spacer()
                            TextField("0", text: $targetValue)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            
                            if inputType == .numeric {
                                TextField("unit", text: $unit)
                                    .frame(width: 60)
                            } else {
                                Text("min")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addHabit()
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
    
    private var frequency: HabitFrequency {
        switch frequencyType {
        case .daily:
            return .daily
        case .weekly:
            return .weekly(daysPerWeek: daysPerWeek)
        case .specificDays:
            return .specificDays(days: Array(selectedDays).sorted())
        }
    }
    
    private func addHabit() {
        var target: Double? = nil
        var habitUnit: String? = nil
        
        if inputType == .numeric || inputType == .duration {
            target = Double(targetValue)
            habitUnit = inputType == .duration ? "min" : (unit.isEmpty ? nil : unit)
        }
        
        let habit = HabitTemplate(
            title: title.trimmingCharacters(in: .whitespaces),
            category: category,
            frequency: frequency,
            inputType: inputType,
            targetValue: target,
            unit: habitUnit,
            isCore: false,
            isActive: true
        )
        
        Task {
            await habitService.addHabit(habit)
            dismiss()
        }
    }
}

// MARK: - Day Selector

public struct DaySelector: View {
    @Binding var selectedDays: Set<Int>
    
    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    public var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { day in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(days[day - 1])
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 36, height: 36)
                        .background(selectedDays.contains(day) ? Color.accentColor : Color(.systemGray5))
                        .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Edit Habit Sheet

public struct EditHabitSheet: View {
    let habit: HabitTemplate
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String = ""
    @State private var category: HabitCategory = .custom
    @State private var inputType: HabitInputType = .boolean
    @State private var frequencyType: AddHabitSheet.FrequencyType = .daily
    @State private var daysPerWeek: Int = 3
    @State private var selectedDays: Set<Int> = []
    @State private var targetValue: String = ""
    @State private var unit: String = ""
    @State private var showingDeleteConfirmation = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $title)
                    
                    Picker("Category", selection: $category) {
                        ForEach(HabitCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
                
                Section("Frequency") {
                    Picker("Frequency", selection: $frequencyType) {
                        ForEach(AddHabitSheet.FrequencyType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if frequencyType == .weekly {
                        Stepper("Days per week: \(daysPerWeek)", value: $daysPerWeek, in: 1...7)
                    }
                    
                    if frequencyType == .specificDays {
                        DaySelector(selectedDays: $selectedDays)
                    }
                }
                
                Section("Tracking Type") {
                    Picker("Input Type", selection: $inputType) {
                        ForEach(HabitInputType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if inputType == .numeric || inputType == .duration {
                        HStack {
                            Text("Target")
                            Spacer()
                            TextField("0", text: $targetValue)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            
                            if inputType == .numeric {
                                TextField("unit", text: $unit)
                                    .frame(width: 60)
                            } else {
                                Text("min")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Habit", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadHabit()
            }
            .alert("Delete Habit", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        await habitService.deleteHabit(habit)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func loadHabit() {
        title = habit.title
        category = habit.category
        inputType = habit.inputType
        
        switch habit.frequency {
        case .daily:
            frequencyType = .daily
        case .weekly(let days):
            frequencyType = .weekly
            daysPerWeek = days
        case .specificDays(let days):
            frequencyType = .specificDays
            selectedDays = Set(days)
        case .custom:
            frequencyType = .daily
        }
        
        if let target = habit.targetValue {
            targetValue = String(Int(target))
        }
        if let u = habit.unit {
            unit = u
        }
    }
    
    private var frequency: HabitFrequency {
        switch frequencyType {
        case .daily:
            return .daily
        case .weekly:
            return .weekly(daysPerWeek: daysPerWeek)
        case .specificDays:
            return .specificDays(days: Array(selectedDays).sorted())
        }
    }
    
    private func saveHabit() {
        var target: Double? = nil
        var habitUnit: String? = nil
        
        if inputType == .numeric || inputType == .duration {
            target = Double(targetValue)
            habitUnit = inputType == .duration ? "min" : (unit.isEmpty ? nil : unit)
        }
        
        var updatedHabit = habit
        updatedHabit.title = title.trimmingCharacters(in: .whitespaces)
        updatedHabit.category = category
        updatedHabit.frequency = frequency
        updatedHabit.inputType = inputType
        updatedHabit.targetValue = target
        updatedHabit.unit = habitUnit
        updatedHabit.updatedAt = Date()
        
        Task {
            await habitService.updateHabit(updatedHabit)
            dismiss()
        }
    }
}

#Preview {
    AddHabitSheet()
        .environmentObject(HabitService())
        .environmentObject(ThemeService())
}
