import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel = HabitsViewModel()
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    if let habits = viewModel.habitsByCategory[category], !habits.isEmpty {
                        Section(header: Text(category.rawValue)) {
                            ForEach(habits) { habit in
                                HabitListRow(habit: habit) {
                                    viewModel.toggleHabit(habit)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadHabits()
            }
        }
    }
}

struct HabitListRow: View {
    let habit: HabitTemplate
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habit.title)
                    .font(.body)
                
                HStack {
                    if habit.isCoreHabit {
                        Text("Core Habit")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    
                    Text(habit.inputType.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { habit.isActive },
                set: { _ in onToggle() }
            ))
        }
    }
}

struct AddHabitView: View {
    @ObservedObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var category: HabitCategory = .custom
    @State private var frequency: HabitFrequency = .daily
    @State private var inputType: HabitInputType = .boolean
    @State private var targetValue = ""
    @State private var unit = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                
                Picker("Category", selection: $category) {
                    ForEach(HabitCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                
                Picker("Frequency", selection: $frequency) {
                    Text("Daily").tag(HabitFrequency.daily)
                    Text("Weekly").tag(HabitFrequency.weekly)
                    Text("Custom").tag(HabitFrequency.custom)
                }
                
                Picker("Input Type", selection: $inputType) {
                    Text("Yes/No").tag(HabitInputType.boolean)
                    Text("Number").tag(HabitInputType.numeric)
                    Text("Duration").tag(HabitInputType.duration)
                    Text("Note").tag(HabitInputType.note)
                }
                
                if inputType == .numeric {
                    TextField("Target Value", text: $targetValue)
                        .keyboardType(.decimalPad)
                    TextField("Unit (e.g., oz, g, min)", text: $unit)
                }
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let target = Double(targetValue)
                        viewModel.addHabit(
                            title: title,
                            category: category,
                            frequency: frequency,
                            inputType: inputType,
                            targetValue: target,
                            unit: unit.isEmpty ? nil : unit
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    HabitsView()
}
