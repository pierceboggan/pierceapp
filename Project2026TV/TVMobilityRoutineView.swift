import SwiftUI

/// Full-screen mobility routine view optimized for TV viewing.
/// Features large timer, exercise info, and remote-friendly navigation.
struct TVMobilityRoutineView: View {
    @Environment(TVMobilityService.self) private var mobilityService
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var timeRemaining: Int = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isCompleted = false
    @State private var timer: Timer?
    
    private let routine = TVMobilityRoutine.bikeRoutine
    
    private var currentExercise: TVMobilityExercise {
        routine.exercises[currentExerciseIndex]
    }
    
    private var progress: Double {
        guard currentExercise.durationSeconds > 0 else { return 0 }
        return Double(currentExercise.durationSeconds - timeRemaining) / Double(currentExercise.durationSeconds)
    }
    
    var body: some View {
        Group {
            if isCompleted {
                completionView
            } else {
                routineView
            }
        }
        .onAppear {
            startExercise()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onPlayPauseCommand {
            togglePause()
        }
        .onExitCommand {
            if isPaused {
                dismiss()
            } else {
                isPaused = true
                timer?.invalidate()
            }
        }
    }
    
    // MARK: - Routine View
    
    private var routineView: some View {
        HStack(spacing: 80) {
            // Left side - Timer
            VStack(spacing: 40) {
                // Exercise counter
                Text("Exercise \(currentExerciseIndex + 1) of \(routine.exercises.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                // Large circular timer
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                        .frame(width: 400, height: 400)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.blue,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 400, height: 400)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    // Time display
                    VStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 100, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        
                        if isPaused {
                            Text("PAUSED")
                                .font(.title2)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                // Play/Pause instruction
                HStack(spacing: 16) {
                    Image(systemName: "playpause.fill")
                    Text(isPaused ? "Press to Resume" : "Press to Pause")
                }
                .font(.headline)
                .foregroundStyle(.secondary)
            }
            
            // Right side - Exercise info
            VStack(alignment: .leading, spacing: 30) {
                // Exercise icon and name
                HStack(spacing: 24) {
                    Image(systemName: currentExercise.iconName)
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentExercise.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(currentExercise.targetArea)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Instructions
                Text("Instructions")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(currentExercise.instructions)
                    .font(.title3)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Navigation hints
                HStack(spacing: 40) {
                    if currentExerciseIndex > 0 {
                        Label("Previous", systemImage: "chevron.left")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if currentExerciseIndex < routine.exercises.count - 1 {
                        Label("Skip", systemImage: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.headline)
            }
            .frame(maxWidth: 600)
        }
        .padding(80)
        .background(Color.black.opacity(0.9))
        .focusable()
        .onMoveCommand { direction in
            switch direction {
            case .left:
                previousExercise()
            case .right:
                skipExercise()
            default:
                break
            }
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 50) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 150))
                .foregroundStyle(.green)
            
            Text("Routine Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Great job! You've completed your mobility routine.")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 60) {
                StatCard(title: "Duration", value: routine.totalDurationMinutes, unit: "minutes")
                StatCard(title: "Exercises", value: routine.exercises.count, unit: "completed")
                StatCard(title: "Streak", value: mobilityService.currentStreak + 1, unit: "days")
            }
            
            Button {
                mobilityService.recordSession(minutes: routine.totalDurationMinutes)
                dismiss()
            } label: {
                Text("Done")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 80)
                    .padding(.vertical, 20)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(80)
    }
    
    // MARK: - Timer Logic
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startExercise() {
        timeRemaining = currentExercise.durationSeconds
        isRunning = true
        isPaused = false
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                moveToNextExercise()
            }
        }
    }
    
    private func togglePause() {
        if isPaused {
            isPaused = false
            startTimer()
        } else {
            isPaused = true
            timer?.invalidate()
        }
    }
    
    private func moveToNextExercise() {
        timer?.invalidate()
        
        if currentExerciseIndex < routine.exercises.count - 1 {
            currentExerciseIndex += 1
            startExercise()
        } else {
            isCompleted = true
        }
    }
    
    private func skipExercise() {
        timer?.invalidate()
        
        if currentExerciseIndex < routine.exercises.count - 1 {
            currentExerciseIndex += 1
            startExercise()
        } else {
            isCompleted = true
        }
    }
    
    private func previousExercise() {
        guard currentExerciseIndex > 0 else { return }
        timer?.invalidate()
        currentExerciseIndex -= 1
        startExercise()
    }
}

#Preview {
    TVMobilityRoutineView()
        .environment(TVMobilityService())
}
