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

### Complete Step-by-Step Video Recording Workflow:

#### Step 1: Set Up MCP Session Defaults (Required First!)
Before any simulator automation, configure session defaults to avoid passing IDs repeatedly:
```javascript
mcp_xcodebuildmcp_session_set_defaults({
    scheme: "Project2026",
    simulatorId: "SIMULATOR_UUID",  // Get from list_sims or mcp_xcodebuildmcp_list_sims
    workspacePath: "/Users/pierce/Documents/GitHub/pierceapp/Project2026.xcworkspace"
})
```

#### Step 2: Build and Launch App
```javascript
// Build and run in simulator
mcp_xcodebuildmcp_build_run_sim()  // Uses session defaults
```

#### Step 3: Take Initial Screenshot to Verify State
```javascript
mcp_xcodebuildmcp_screenshot()  // Returns image showing current screen
```

#### Step 4: Start Video Recording
```javascript
mcp_xcodebuildmcp_record_sim_video({
    start: true,
    fps: 30  // Optional, default is 30
})
// Returns session ID like "49FC08B5-B194-49B8-8898-ABFECBC2E48F:1767057630003"
```

#### Step 5: Navigate and Interact with UI
Use these tools to demonstrate the feature:

```javascript
// Tap by accessibility label (preferred)
mcp_xcodebuildmcp_tap({
    label: "Fitness",  // Accessibility label
    postDelay: 0.5     // Wait after tap for animations
})

// Tap by coordinates (when labels unavailable)
mcp_xcodebuildmcp_tap({
    x: 110,
    y: 810,
    postDelay: 0.5
})

// Get UI hierarchy to find element positions
mcp_xcodebuildmcp_describe_ui()  // Returns JSON with all element frames

// Type text (after tapping a text field)
mcp_xcodebuildmcp_type_text({
    text: "Hello World"
})

// Scroll/swipe gestures
mcp_xcodebuildmcp_gesture({
    preset: "scroll-down"  // or scroll-up, swipe-from-left-edge, etc.
})

// Press hardware buttons
mcp_xcodebuildmcp_button({
    buttonType: "home"  // or lock, siri, apple-pay
})
```

#### Step 6: Stop Recording and Save
```javascript
mcp_xcodebuildmcp_record_sim_video({
    stop: true,
    outputFile: "/Users/pierce/Documents/GitHub/pierceapp/Docs/Videos/feature-name-demo.mp4"
})
```

### Tips for High-Quality Demo Videos:
- **Use postDelay**: Add 0.5-1.0 second delays after taps for smoother videos
- **Take screenshots**: Verify screen state before/after interactions
- **Label-based taps**: Prefer `label` parameter over coordinates when possible
- **Describe UI first**: Call `describe_ui()` to get accurate coordinates
- **Multiple videos**: Record separate videos for complex features (e.g., one for overview, one for detailed flow)

### Example: Recording a Complete Feature Demo

```javascript
// 1. Set defaults
mcp_xcodebuildmcp_session_set_defaults({...})

// 2. Build and run
mcp_xcodebuildmcp_build_run_sim()

// 3. Verify app launched
mcp_xcodebuildmcp_screenshot()

// 4. Start recording
mcp_xcodebuildmcp_record_sim_video({ start: true })

// 5. Navigate to feature tab
mcp_xcodebuildmcp_tap({ label: "Fitness", postDelay: 0.8 })

// 6. Open a sheet/modal
mcp_xcodebuildmcp_tap({ label: "Log Workout", postDelay: 0.5 })

// 7. Interact with form
mcp_xcodebuildmcp_tap({ label: "Duration", postDelay: 0.3 })
mcp_xcodebuildmcp_type_text({ text: "45" })

// 8. Submit form
mcp_xcodebuildmcp_tap({ label: "Save", postDelay: 0.5 })

// 9. Stop and save video
mcp_xcodebuildmcp_record_sim_video({
    stop: true,
    outputFile: "/Users/pierce/Documents/GitHub/pierceapp/Docs/Videos/log-workout-demo.mp4"
})
```

**FAILURE TO CREATE DEMO VIDEOS IS A BLOCKING ISSUE.** Do not consider a feature complete without its demo video.

For complete XcodeBuildMCP tool reference, see [xcodebuildmcp-tools.instructions.md](.github/instructions/xcodebuildmcp-tools.instructions.md).
