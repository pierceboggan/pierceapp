import SwiftUI

/// Main tvOS app entry point for Project 2026.
/// Focuses on mobility routines for big-screen TV experience.
@main
struct Project2026TVApp: App {
    @State private var mobilityService = TVMobilityService()
    @State private var statsService = TVStatsService()
    
    var body: some Scene {
        WindowGroup {
            TVContentView()
                .environment(mobilityService)
                .environment(statsService)
        }
    }
}
