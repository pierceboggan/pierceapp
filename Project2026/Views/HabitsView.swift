//
//  HabitsView.swift
//  Project2026
//
//  View for managing habits
//

import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var showingAddHabit = false
    @State private var selectedCategory: HabitCategory?
    @State private var showArchived = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        NavigationStack {
            List {
                // Category Filter
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                color: theme.primary
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(HabitCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    color: categoryColor(category)
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                // Active Habits
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    let habits = filteredHabits(for: category)
                    if !habits.isEmpty {
                        Section {
                            ForEach(habits) { habit in
                                HabitManagementRow(habit: habit)
                            }
                        } header: {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(categoryColor(category))
                                Text(category.rawValue)
                            }
                        }
                    }
                }
                
                // Archived Habits
                if showArchived {
                    let archived = habitService.habitTemplates.filter { !$0.isActive }
                    if !archived.isEmpty {
                        Section("Archived") {
                            ForEach(archived) { habit in
                                HabitManagementRow(habit: habit, isArchived: true)
                            }
                        }
                    }
                }
                
                // Show/Hide Archived
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
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitSheet()
            }
        }
    }
    
    private func filteredHabits(for category: HabitCategory) -> [HabitTemplate] {
        let activeHabits = habitService.habitTemplates.filter { $0.isActive }
        
        if let selected = selectedCategory {
            return activeHabits.filter { $0.category == selected && $0.category == category }
        } else {
            return activeHabits.filter { $0.category == category }
        }
    }
    
    private func categoryColor(_ category: HabitCategory) -> Color {
        switch category {
        case .life: return .blue
        case .fitness: return .orange
        case .nutrition: return .green
        case .health: return .red
        case .work: return .purple
        case .supplements: return .teal
        case .custom: return .yellow
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : color.opacity(0.1))
                .foregroundColor(isSelected ? .white : color)
                .cornerRadius(16)
        }
    }
}

// MARK: - Habit Management Row

struct HabitManagementRow: View {
    let habit: HabitTemplate
    var isArchived: Bool = false
    
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var themeService: ThemeService
    @State private var showingEdit = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        HStack {
            // Toggle Active
            Button {
                Task {
                    await habitService.toggleHabit(habit)
                }
            } label: {
                Image(systemName: habit.isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isActive ? theme.positive : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(habit.title)
                        .font(.subheadline)
                        .foregroundColor(isArchived ? .secondary : .primary)
                    
                    if habit.isCore {
                        Text("Core")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.primary.opacity(0.1))
                            .foregroundColor(theme.primary)
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 8) {
                    // Frequency
                    Text(habit.frequency.displayText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Input Type
                    if habit.inputType != .boolean {
                        Label(habit.inputType.rawValue, systemImage: habit.inputType.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Target
                    if let target = habit.targetValue, let unit = habit.unit {
                        Text("\(Int(target))\(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Streak
            if !isArchived {
                let streak = habitService.streak(for: habit)
                if streak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streak)")
                            .fontWeight(.medium)
                    }
                    .font(.caption)
                }
            }
            
            // Edit Button (only for custom habits)
            if !habit.isCore {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditHabitSheet(habit: habit)
        }
    }
}

// MARK: - Preview

#Preview {
    HabitsView()
        .environmentObject(HabitService())
        .environmentObject(ThemeService())
}
