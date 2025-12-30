import SwiftUI

/// Main view for the bike mobility routine
@MainActor
struct MobilityRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workoutService: WorkoutService
    @State private var timerService = MobilityTimerService()
    @State private var showInstructions = false
    @State private var startTime: Date?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if timerService.isComplete {
                    completionView
                } else if let exercise = timerService.currentExercise {
                    exerciseView(exercise)
                } else {
                    startView
                }
            }
            .navigationTitle("Mobility Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !timerService.isComplete {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showInstructions = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showInstructions) {
                if let exercise = timerService.currentExercise {
                    ExerciseInstructionsSheet(exercise: exercise)
                }
            }
        }
    }
    
    private var startView: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Bike-Mobility & Knee Health")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("\(MobilityRoutine.bikeRoutine.exercises.count) exercises • ~\(MobilityRoutine.bikeRoutine.totalDuration / 60) minutes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                startTime = Date()
                timerService.start()
            } label: {
                Text("Start Routine")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
        .padding()
    }
    
    private func exerciseView(_ exercise: MobilityExercise) -> some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                Rectangle()
                    .fill(.blue.opacity(0.3))
                    .frame(width: geometry.size.width)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(.blue)
                            .frame(width: geometry.size.width * timerService.progress)
                    }
            }
            .frame(height: 6)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Exercise counter
                    Text("Exercise \(timerService.currentExerciseIndex + 1) of \(MobilityRoutine.bikeRoutine.exercises.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                    
                    // Timer display
                    Text(timerService.formattedTimeRemaining())
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    // Exercise name
                    Text(exercise.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Reps/hold description
                    if let reps = exercise.repsOrHoldDescription {
                        Text(reps)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Quick tips
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Quick Tips", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        ForEach(exercise.cues, id: \.self) { cue in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .fontWeight(.bold)
                                Text(cue)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Control buttons
                    HStack(spacing: 16) {
                        Button {
                            timerService.skipToPrevious()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                                .frame(width: 60, height: 60)
                                .background(.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .disabled(timerService.currentExerciseIndex == 0)
                        
                        Button {
                            if timerService.isPaused {
                                timerService.resume()
                            } else if timerService.isRunning {
                                timerService.pause()
                            } else {
                                timerService.start()
                            }
                        } label: {
                            Image(systemName: timerService.isPaused ? "play.fill" : "pause.fill")
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                        }
                        
                        Button {
                            timerService.skipToNext()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .frame(width: 60, height: 60)
                                .background(.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Routine Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Great work! Your body will thank you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                startTime = Date()
                timerService.reset()
                timerService.start()
            } label: {
                Text("Start Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Button {
                logMobilityCompletion()
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }
    
    private func logMobilityCompletion() {
        let duration: Int
        if let start = startTime {
            duration = Int(Date().timeIntervalSince(start) / 60)
        } else {
            duration = MobilityRoutine.bikeRoutine.totalDuration / 60
        }
        
        Task {
            await workoutService.logMobilitySession(
                durationMinutes: max(duration, 1),
                exercisesCompleted: MobilityRoutine.bikeRoutine.exercises.count,
                totalExercises: MobilityRoutine.bikeRoutine.exercises.count
            )
        }
    }
}

#Preview {
    MobilityRoutineView()
        .environmentObject(WorkoutService())
}
