import Foundation
import AVFoundation

/// Manages timer state and beeps for mobility routine
@Observable
@MainActor
final class MobilityTimerService {
    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var currentExerciseIndex = 0
    private(set) var timeRemaining: Int = 0
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
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
        setupAudio()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
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
        playBeep(type: .start)
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
            playBeep(type: .start)
        } else {
            stop()
            playBeep(type: .complete)
        }
    }
    
    func skipToPrevious() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            timeRemaining = routine.exercises[currentExerciseIndex].durationSeconds
            playBeep(type: .start)
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
        
        // Beep at 10, 5, 3, 2, 1 seconds remaining
        if [10, 5, 3, 2, 1].contains(timeRemaining) {
            playBeep(type: .countdown)
        }
        
        // Beep when exercise completes
        if timeRemaining == 0 {
            playBeep(type: .exerciseComplete)
        }
    }
    
    private func playBeep(type: BeepType) {
        // Generate a simple beep tone
        let systemSoundID: SystemSoundID
        
        switch type {
        case .start:
            systemSoundID = 1054 // Three short beeps
        case .countdown:
            systemSoundID = 1103 // Short beep
        case .exerciseComplete:
            systemSoundID = 1057 // Two beeps
        case .complete:
            systemSoundID = 1025 // Success sound
        }
        
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    enum BeepType {
        case start
        case countdown
        case exerciseComplete
        case complete
    }
    
    func formattedTimeRemaining() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
