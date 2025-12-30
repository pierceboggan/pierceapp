import SwiftUI

/// Sheet showing detailed exercise instructions
struct ExerciseInstructionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: MobilityExercise
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Exercise Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                Divider()
                instructionsSection
                cuesSection
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.title)
                .fontWeight(.bold)
            
            durationLabel
        }
    }
    
    private var durationLabel: some View {
        HStack {
            Label("\(exercise.durationSeconds)s", systemImage: "clock")
            if let reps = exercise.repsOrHoldDescription {
                Text("•")
                Text(reps)
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Instructions", systemImage: "list.number")
                .font(.headline)
            
            ForEach(Array(exercise.howToDoIt.enumerated()), id: \.offset) { index, instruction in
                instructionRow(index: index, instruction: instruction)
            }
        }
    }
    
    private func instructionRow(index: Int, instruction: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index + 1).")
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(instruction)
        }
    }
    
    private var cuesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Key Cues", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(.orange)
            
            ForEach(exercise.cues, id: \.self) { cue in
                cueRow(cue: cue)
            }
        }
        .padding()
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func cueRow(cue: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(cue)
        }
    }
}

#Preview {
    ExerciseInstructionsSheet(exercise: MobilityRoutine.bikeRoutine.exercises[0])
}
