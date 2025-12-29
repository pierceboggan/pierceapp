import SwiftUI

/// Detailed instructions sheet for an exercise
struct ExerciseInstructionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: MobilityExercise
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Exercise name
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Why section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Why", systemImage: "questionmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        
                        Text(exercise.why)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // How to do it section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How to Do It", systemImage: "list.bullet.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        ForEach(Array(exercise.howToDoIt.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                                Text(step)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Cues section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Key Cues", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        ForEach(exercise.cues, id: \.self) { cue in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                                Text(cue)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Duration info
                    if let reps = exercise.repsOrHoldDescription {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.purple)
                            Text(reps)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(exercise.durationSeconds)s")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(.purple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExerciseInstructionsSheet(
        exercise: MobilityRoutine.bikeRoutine.exercises[0]
    )
}
