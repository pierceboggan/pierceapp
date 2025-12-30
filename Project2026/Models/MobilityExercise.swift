import Foundation

/// Represents a single mobility exercise with instructions and timing
struct MobilityExercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let why: String
    let howToDoIt: [String]
    let cues: [String]
    let durationSeconds: Int
    let repsOrHoldDescription: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        why: String,
        howToDoIt: [String],
        cues: [String],
        durationSeconds: Int,
        repsOrHoldDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.why = why
        self.howToDoIt = howToDoIt
        self.cues = cues
        self.durationSeconds = durationSeconds
        self.repsOrHoldDescription = repsOrHoldDescription
    }
}

/// The complete bike mobility routine
struct MobilityRoutine {
    let title: String
    let exercises: [MobilityExercise]
    
    var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.durationSeconds }
    }
    
    static let bikeRoutine = MobilityRoutine(
        title: "Bike-Mobility & Knee Health Routine",
        exercises: [
            MobilityExercise(
                name: "Cat–Cow + Thoracic Reach",
                why: "Mobilizes spine for better aero position and breathing.",
                howToDoIt: [
                    "On hands & knees (wrists under shoulders, knees under hips).",
                    "Cow: Inhale, drop belly, lift chest, look forward.",
                    "Cat: Exhale, round spine up, tuck chin and pelvis.",
                    "Repeat 6 slow cycles.",
                    "Then do Thoracic Reach: from all-fours, place left hand behind head → rotate elbow up toward ceiling then down toward opposite arm. 3 reps per side."
                ],
                cues: [
                    "Move from mid-back (not just neck)",
                    "Keep core engaged",
                    "Move fluidly"
                ],
                durationSeconds: 90,
                repsOrHoldDescription: "6 cycles + 3 reps per side"
            ),
            MobilityExercise(
                name: "Hip Flexor / Psoas Lunge Stretch",
                why: "Releases tight hip flexors so pelvis can orient for aero posture and relieve hamstring pull.",
                howToDoIt: [
                    "Step into a half-kneeling lunge.",
                    "Tuck pelvis (like zipping up jeans), squeeze glute of back leg.",
                    "Lean forward gently until you feel stretch in front of the hip.",
                    "Hold for 30 sec each side."
                ],
                cues: [
                    "Keep spine neutral",
                    "Glutes squeezed",
                    "Avoid over-arching lower back"
                ],
                durationSeconds: 60,
                repsOrHoldDescription: "30 sec each side"
            ),
            MobilityExercise(
                name: "Hamstring Glide (Not Passive Stretch)",
                why: "Encourages posterior chain mobility + neural glide — often more helpful for cyclists than static stretching.",
                howToDoIt: [
                    "Sit tall with one leg straight, heel on ground, foot flexed.",
                    "Keep spine long.",
                    "Slowly bend and straighten knee (heel stays down).",
                    "Do 10 slow reps each leg."
                ],
                cues: [
                    "Move from hips",
                    "Don't round the lower back",
                    "Focus on gentle sliding, not forced stretch"
                ],
                durationSeconds: 60,
                repsOrHoldDescription: "10 reps each leg"
            ),
            MobilityExercise(
                name: "Sciatic-Nerve Floss",
                why: "Helps relieve neural tension that might feel like \"tight hamstrings\" — can reduce discomfort and improve mobility.",
                howToDoIt: [
                    "Lie on back. Lift one leg, hands behind thigh.",
                    "Straighten knee + flex foot (toes toward you) → then bend knee + point toes away.",
                    "Smooth rhythm. 10–12 reps per leg."
                ],
                cues: [
                    "Control the movement",
                    "Stop if you feel sharp nerve pain"
                ],
                durationSeconds: 60,
                repsOrHoldDescription: "10-12 reps per leg"
            ),
            MobilityExercise(
                name: "Adductor Rock-Backs",
                why: "Opens inner hips and improves hip mobility and leg alignment — often helpful for knee tracking.",
                howToDoIt: [
                    "On hands & knees, extend one leg sideways, foot flat.",
                    "Sink hips back toward same-side heel, keeping spine long.",
                    "Rock hip back and forth gently. 10–12 reps each side."
                ],
                cues: [
                    "Keep chest up",
                    "Avoid rounding back",
                    "Move from hips"
                ],
                durationSeconds: 60,
                repsOrHoldDescription: "10-12 reps each side"
            ),
            MobilityExercise(
                name: "Glute-Med Activation — Side-Lying Leg Lift",
                why: "Activates glutes rather than letting quads/hamstrings dominate — crucial for knee stability and efficient pedal stroke.",
                howToDoIt: [
                    "Lie on one side, bottom knee slightly bent.",
                    "Top leg straight, toe angled slightly down.",
                    "Lift leg ~12–18 in slowly without rotating hips. 12–15 reps per side."
                ],
                cues: [
                    "Don't let hips rock",
                    "Focus on \"side-butt\" (glute med), not quads"
                ],
                durationSeconds: 60,
                repsOrHoldDescription: "12-15 reps per side"
            ),
            MobilityExercise(
                name: "Calf + Tibialis Wall Stretch",
                why: "Balanced lower leg tension → reduces strain on knees and improves pedal mechanics.",
                howToDoIt: [
                    "Face wall, hands on wall.",
                    "Place ball of foot on wall, heel down. Lean forward till you stretch calf (gastrocnemius). Hold 30 sec.",
                    "Then bend knee slightly to stretch soleus. Hold 30 sec."
                ],
                cues: [
                    "Keep heel pinned down",
                    "Spine neutral",
                    "Avoid rotating hips"
                ],
                durationSeconds: 60,
                repsOrHoldDescription: "30 sec + 30 sec each side"
            ),
            MobilityExercise(
                name: "Thoracic Bench / Counter Stretch",
                why: "Opens upper back and lats — helps maintain better posture on the bike and avoid rounding.",
                howToDoIt: [
                    "Kneel in front of bench / counter.",
                    "Place elbows on surface, hands clasped.",
                    "Sink chest toward floor as you inhale and expand ribs. Hold 1 minute."
                ],
                cues: [
                    "Relax lower back",
                    "Focus on rib expansion and gentle forward lean"
                ],
                durationSeconds: 60,
                repsOrHoldDescription: "Hold 1 minute"
            ),
            MobilityExercise(
                name: "Pelvic Tilt Cycling Drill",
                why: "Helps you find optimal pelvic position (neutral to slight anterior tilt), improving aero posture and reducing lower-back/knee stress.",
                howToDoIt: [
                    "Sit on saddle (or simply stand).",
                    "Alternate between posterior pelvic tilt (tuck butt under) and anterior tilt (stick butt slightly out), then end in a gentle neutral-anterior tilt.",
                    "10 slow cycles."
                ],
                cues: [
                    "Keep spine straight",
                    "Move from hips",
                    "Feel subtle pelvic motion"
                ],
                durationSeconds: 45,
                repsOrHoldDescription: "10 slow cycles"
            ),
            MobilityExercise(
                name: "Monster Walk — Glute + Hip Stability",
                why: "Activates hip abductors / glutes to stabilize pelvis and knees — especially important given your knee history.",
                howToDoIt: [
                    "Place a mini-loop resistance band just above ankles (harder) or above knees (easier).",
                    "Get into a semi-squat: feet shoulder-width, knees and hips bent ~30°, chest up, core engaged.",
                    "Step to the side (or diagonally) with one foot, then the other—keeping band tension, knees over toes, toes forward.",
                    "Take small, controlled steps. Keep torso tall; don't let knees collapse inward."
                ],
                cues: [
                    "Maintain band tension",
                    "Squat slightly",
                    "Move slowly",
                    "Feel activation in glutes and outer hips, not quads"
                ],
                durationSeconds: 90,
                repsOrHoldDescription: "2-3 sets of ~20 steps each direction"
            )
        ]
    )
}
