//
//  MacMobilityRoutineView.swift
//  Project2026Mac
//
//  macOS-optimized mobility routine view
//

import SwiftUI
import AVFoundation

/// macOS-optimized mobility routine view with keyboard controls
struct MacMobilityRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timerService = MobilityTimerServiceMac()
    @State private var showInstructions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Text("Mobility Routine")
                    .font(.headline)
                
                Spacer()
                
                if !timerService.isComplete {
                    Button {
                        showInstructions.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .padding()
            .background(.bar)
            
            Divider()
            
            // Main content
            if timerService.isComplete {
                completionView
            } else if let exercise = timerService.currentExercise {
                exerciseView(exercise)
            } else {
                startView
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            setupKeyboardShortcuts()
        }
    }
    
    private var startView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Bike-Mobility & Knee Health")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(MobilityRoutine.bikeRoutine.exercises.count) exercises • ~\(MobilityRoutine.bikeRoutine.totalDuration / 60) minutes")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Button {
                timerService.start()
            } label: {
                Text("Start Routine")
                    .font(.title3)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return)
            
            Text("Press Return to start • Space to pause/resume • Arrow keys to skip")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding(32)
    }
    
    private func exerciseView(_ exercise: MobilityExercise) -> some View {
        HSplitView {
            // Left: Timer and controls
            VStack(spacing: 24) {
                Spacer()
                
                // Progress
                Text("Exercise \(timerService.currentExerciseIndex + 1) of \(MobilityRoutine.bikeRoutine.exercises.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Timer
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: timerService.progress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text(timerService.formattedTimeRemaining())
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        
                        Text("remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                
                // Controls
                HStack(spacing: 24) {
                    Button {
                        timerService.skipToPrevious()
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.bordered)
                    .disabled(timerService.currentExerciseIndex == 0)
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    
                    Button {
                        if timerService.isPaused {
                            timerService.resume()
                        } else if timerService.isRunning {
                            timerService.pause()
                        }
                    } label: {
                        Image(systemName: timerService.isPaused ? "play.fill" : "pause.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.space, modifiers: [])
                    
                    Button {
                        timerService.skipToNext()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.rightArrow, modifiers: [])
                }
                
                Spacer()
            }
            .frame(minWidth: 300)
            .padding(24)
            
            // Right: Exercise info
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let reps = exercise.repsOrHoldDescription {
                        Label(reps, systemImage: "repeat")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                    
                    Divider()
                    
                    // Why section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Why", systemImage: "questionmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        Text(exercise.why)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Quick tips
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Quick Tips", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        ForEach(exercise.cues, id: \.self) { cue in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .fontWeight(.bold)
                                Text(cue)
                            }
                        }
                    }
                    
                    if showInstructions {
                        Divider()
                        
                        // Full instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Label("How To Do It", systemImage: "list.number")
                                .font(.headline)
                                .foregroundStyle(.purple)
                            
                            ForEach(Array(exercise.howToDoIt.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .fontWeight(.bold)
                                        .frame(width: 24, alignment: .trailing)
                                    Text(step)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .frame(minWidth: 300)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Routine Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Great work! Your body will thank you.")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                Button {
                    timerService.reset()
                } label: {
                    Text("Start Again")
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.bordered)
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
            
            Spacer()
        }
        .padding(32)
    }
    
    private func setupKeyboardShortcuts() {
        // Keyboard shortcuts are handled via button modifiers
    }
}

// MARK: - macOS Timer Service

@Observable
@MainActor
final class MobilityTimerServiceMac {
    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var currentExerciseIndex = 0
    private(set) var timeRemaining: Int = 0
    
    private var timer: Timer?
    private let routine: MobilityRoutine
    
    var currentExercise: MobilityExercise? {
        guard currentExerciseIndex < routine.exercises.count else { return nil }
        return routine.exercises[currentExerciseIndex]
    }
    
    var progress: Double {
        guard let exercise = currentExercise else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(exercise.durationSeconds))
    }
    
    var isComplete: Bool {
        currentExerciseIndex >= routine.exercises.count
    }
    
    init(routine: MobilityRoutine = .bikeRoutine) {
        self.routine = routine
    }
    
    func start() {
        guard !isRunning else { return }
        
        if currentExerciseIndex >= routine.exercises.count {
            reset()
        }
        
        isRunning = true
        isPaused = false
        
        if timeRemaining == 0 {
            timeRemaining = routine.exercises[currentExerciseIndex].durationSeconds
        }
        
        startTimer()
        playSound(.start)
    }
    
    func pause() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        guard isPaused else { return }
        isPaused = false
        startTimer()
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        stop()
        currentExerciseIndex = 0
        timeRemaining = 0
    }
    
    func skipToNext() {
        currentExerciseIndex += 1
        
        if currentExerciseIndex < routine.exercises.count {
            timeRemaining = routine.exercises[currentExerciseIndex].durationSeconds
            playSound(.start)
        } else {
            stop()
            playSound(.complete)
        }
    }
    
    func skipToPrevious() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            timeRemaining = routine.exercises[currentExerciseIndex].durationSeconds
            playSound(.start)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            skipToNext()
            return
        }
        
        timeRemaining -= 1
        
        if [10, 5, 3, 2, 1].contains(timeRemaining) {
            playSound(.countdown)
        }
        
        if timeRemaining == 0 {
            playSound(.exerciseComplete)
        }
    }
    
    private func playSound(_ type: SoundType) {
        let soundName: String
        switch type {
        case .start:
            soundName = "Blow"
        case .countdown:
            soundName = "Tink"
        case .exerciseComplete:
            soundName = "Glass"
        case .complete:
            soundName = "Hero"
        }
        
        NSSound(named: soundName)?.play()
    }
    
    enum SoundType {
        case start, countdown, exerciseComplete, complete
    }
    
    func formattedTimeRemaining() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    MacMobilityRoutineView()
}
