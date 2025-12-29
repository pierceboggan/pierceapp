# Copilot Custom Instructions

- This repository uses Swift 6.1+ and SwiftUI for iOS 18+ apps. All code should follow modern Swift and SwiftUI best practices.
- This is an iOS project NOT a pure Swift Package or macOS project. It utlises a local Swift Package which is wrapped in an Xcode project. This makes it easier for agents to work on the project.
- Use the Model-View (MV) pattern with native SwiftUI state management (`@State`, `@Observable`, `@Environment`, `@Binding`). Do not use ViewModels or MVVM.
- All concurrency must use Swift Concurrency (async/await, actors, @MainActor). Do not use GCD or completion handlers.
- Write all new code and features inside the Swift Package (`YourAppPackage`), not in the app shell.
- Use the Swift Testing framework (`@Test`, `#expect`, `#require`) for all tests. Place tests in the package's `Tests/` directory.
- When running tests use the `test_sim_name_ws` tool do not use `swift_package_test`.
- Use XcodeBuildMCP tools for building, testing, and automation. Prefer these over raw xcodebuild or CLI commands.
- For data persistence, use SwiftData (never CoreData), though only use for complex scenarios, prefer simpler options first e.g. UserDefaults.
- Always provide accessibility labels and identifiers for UI elements.
- Never log sensitive information or use insecure network calls.
- Add a short documentation comment (`///`) to every struct, class, enum, and actor describing its purpose.
- For full style, architecture, and workflow details, refer to the project documentation in [`.github/instructions/`](.github/instructions/).

## MANDATORY: Demo Videos for New Features

**YOU MUST create a demo video for EVERY new feature or significant UI change.** This is non-negotiable.

### Video Recording Requirements:
1. **ALWAYS** record a video after implementing a new feature, before marking the task complete
2. Use `mcp_xcodebuildmcp_record_sim_video` with `start: true` to begin recording
3. Navigate through and demonstrate the new feature functionality
4. Use `mcp_xcodebuildmcp_record_sim_video` with `stop: true` and specify `outputFile` to save
5. Save videos to `/Users/pierce/Documents/GitHub/pierceapp/Docs/Videos/` with descriptive names like `feature-name-demo.mp4`

### Video Content Guidelines:
- Show the feature from the user's perspective (navigate to it, interact with it)
- Demonstrate all key functionality and edge cases
- Keep videos concise but complete (15-60 seconds typically)
- For timer-based features, show start/pause/complete flows

### Workflow:
```
1. Build and run app on simulator
2. Start video recording
3. Navigate to and demonstrate the new feature
4. Stop recording and save with descriptive filename
5. Commit video along with code changes
```

**FAILURE TO CREATE DEMO VIDEOS IS A BLOCKING ISSUE.** Do not consider a feature complete without its demo video.
