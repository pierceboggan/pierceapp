---
description: "Comprehensive guide for using XcodeBuildMCP tools for building, testing, deploying, and automating iOS applications. Includes simulator management, device deployment, UI automation, and debugging workflows. Apply when building apps, running tests, automating workflows, or using development tools."
applyTo: "**/*.swift"
---

# XcodeBuildMCP Tool Usage

To work with this project, build, test, and development commands should use XcodeBuildMCP tools instead of raw command-line calls.

## Project Discovery & Setup

```javascript
// Discover Xcode projects in the workspace
discover_projs({
    workspaceRoot: "/path/to/YourApp"
})

// List available schemes
list_schems_ws({
    workspacePath: "/path/to/YourApp.xcworkspace"
})
```

## Building for Simulator

```javascript
// Build for iPhone simulator by name
build_sim_name_ws({
    workspacePath: "/path/to/YourApp.xcworkspace",
    scheme: "YourApp",
    simulatorName: "iPhone 16",
    configuration: "Debug"
})

// Build and run in one step
build_run_sim_name_ws({
    workspacePath: "/path/to/YourApp.xcworkspace",
    scheme: "YourApp", 
    simulatorName: "iPhone 16"
})
```

## Building for Device

```javascript
// List connected devices first
list_devices()

// Build for physical device
build_dev_ws({
    workspacePath: "/path/to/YourApp.xcworkspace",
    scheme: "YourApp",
    configuration: "Debug"
})
```

## Testing

```javascript
// Run tests on simulator
test_sim_name_ws({
    workspacePath: "/path/to/YourApp.xcworkspace",
    scheme: "YourApp",
    simulatorName: "iPhone 16"
})

// Run tests on device
test_device_ws({
    workspacePath: "/path/to/YourApp.xcworkspace",
    scheme: "YourApp",
    deviceId: "DEVICE_UUID_HERE"
})

// Test Swift Package
swift_package_test({
    packagePath: "/path/to/YourAppPackage"
})
```

## Simulator Management

```javascript
// List available simulators
list_sims({
    enabled: true
})

// Boot simulator
boot_sim({
    simulatorUuid: "SIMULATOR_UUID"
})

// Install app
install_app_sim({
    simulatorUuid: "SIMULATOR_UUID",
    appPath: "/path/to/YourApp.app"
})

// Launch app
launch_app_sim({
    simulatorUuid: "SIMULATOR_UUID",
    bundleId: "com.example.YourApp"
})
```

## Device Management

```javascript
// Install on device
install_app_device({
    deviceId: "DEVICE_UUID",
    appPath: "/path/to/YourApp.app"
})

// Launch on device
launch_app_device({
    deviceId: "DEVICE_UUID",
    bundleId: "com.example.YourApp"
})
```

## UI Automation

```javascript
// Get UI hierarchy with precise frame coordinates
describe_ui({
    simulatorUuid: "SIMULATOR_UUID"
})
// Returns JSON tree with frame data (x, y, width, height) for all visible elements
// ALWAYS call this before UI interactions to get accurate coordinates

// Tap element by accessibility label (preferred method)
tap({
    label: "Button Label",  // Accessibility label
    postDelay: 0.5          // Wait after tap for animations
})

// Tap element by coordinates (when labels unavailable)
tap({
    simulatorUuid: "SIMULATOR_UUID",
    x: 100,
    y: 200,
    postDelay: 0.5
})

// Type text (after focusing a text field)
type_text({
    simulatorUuid: "SIMULATOR_UUID",
    text: "Hello World"
})

// Take screenshot
screenshot({
    simulatorUuid: "SIMULATOR_UUID"
})

// Swipe gesture
swipe({
    x1: 200, y1: 600,  // Start point
    x2: 200, y2: 200,  // End point
    duration: 0.3      // Seconds
})

// Long press
long_press({
    x: 200,
    y: 400,
    duration: 1000  // Milliseconds
})

// Preset gestures (scroll, swipe from edges)
gesture({
    preset: "scroll-down"  // scroll-up, scroll-left, scroll-right,
                           // swipe-from-left-edge, swipe-from-right-edge,
                           // swipe-from-top-edge, swipe-from-bottom-edge
})

// Press hardware buttons
button({
    buttonType: "home"  // apple-pay, home, lock, side-button, siri
})
```

## Video Recording (CRITICAL FOR FEATURE DEMOS)

Video recording is **mandatory** for all new features. See the main [copilot-instructions.md](../copilot-instructions.md) for requirements.

### Session Setup (Required First!)
Before any video recording or UI automation, set session defaults:

```javascript
// ALWAYS run this first in a new session
mcp_xcodebuildmcp_session_set_defaults({
    scheme: "Project2026",
    simulatorId: "49FC08B5-B194-49B8-8898-ABFECBC2E48F",  // From list_sims
    workspacePath: "/Users/pierce/Documents/GitHub/pierceapp/Project2026.xcworkspace"
})
```

### Finding Simulator UUID
```javascript
// List all available simulators
mcp_xcodebuildmcp_list_sims()
// Returns list with names and UUIDs like:
// - iPhone 16 (49FC08B5-B194-49B8-8898-ABFECBC2E48F) - iOS 18.4

// Or for physical devices
mcp_xcodebuildmcp_list_devices()
```

### Recording Workflow

```javascript
// 1. Start recording
mcp_xcodebuildmcp_record_sim_video({
    start: true,
    fps: 30  // Optional, default 30, max 120
})
// Returns session ID: "SIMULATOR_UUID:TIMESTAMP"

// 2. Perform UI interactions (see UI Automation section)
mcp_xcodebuildmcp_tap({ label: "Tab Name", postDelay: 0.8 })
mcp_xcodebuildmcp_tap({ label: "Button", postDelay: 0.5 })

// 3. Stop and save recording
mcp_xcodebuildmcp_record_sim_video({
    stop: true,
    outputFile: "/Users/pierce/Documents/GitHub/pierceapp/Docs/Videos/feature-demo.mp4"
})
```

### Video Recording Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `start` | boolean | Set `true` to begin recording |
| `stop` | boolean | Set `true` to end recording |
| `fps` | integer | Frames per second (1-120, default 30) |
| `outputFile` | string | Absolute path to save the MP4 file |

### Video File Naming Convention
Save all videos to: `/Users/pierce/Documents/GitHub/pierceapp/Docs/Videos/`

Naming patterns:
- `feature-name-demo.mp4` - Main feature demonstration
- `feature-name-detailed-flow.mp4` - Detailed walkthrough
- `feature-name-edge-case.mp4` - Specific edge case demo

### Complete Example: Recording Fitness Tab Demo

```javascript
// Step 1: Configure session
mcp_xcodebuildmcp_session_set_defaults({
    scheme: "Project2026",
    simulatorId: "49FC08B5-B194-49B8-8898-ABFECBC2E48F",
    workspacePath: "/Users/pierce/Documents/GitHub/pierceapp/Project2026.xcworkspace"
})

// Step 2: Build and launch app
mcp_xcodebuildmcp_build_run_sim()

// Step 3: Verify app state with screenshot
mcp_xcodebuildmcp_screenshot()

// Step 4: Start video recording
mcp_xcodebuildmcp_record_sim_video({ start: true })

// Step 5: Navigate to Fitness tab
mcp_xcodebuildmcp_tap({ label: "Fitness", postDelay: 0.8 })

// Step 6: Open Log Workout sheet
mcp_xcodebuildmcp_tap({ label: "Log Workout", postDelay: 0.5 })

// Step 7: Close sheet and open mobility routine
mcp_xcodebuildmcp_tap({ x: 196, y: 70, postDelay: 0.5 })  // Cancel button
mcp_xcodebuildmcp_tap({ label: "Start Mobility", postDelay: 0.8 })

// Step 8: Navigate through exercises
mcp_xcodebuildmcp_tap({ label: "Forward", postDelay: 0.8 })
mcp_xcodebuildmcp_tap({ label: "Forward", postDelay: 0.8 })

// Step 9: Stop and save
mcp_xcodebuildmcp_record_sim_video({
    stop: true,
    outputFile: "/Users/pierce/Documents/GitHub/pierceapp/Docs/Videos/fitness-tab-demo.mp4"
})
```

### Troubleshooting Video Recording

| Issue | Solution |
|-------|----------|
| Recording doesn't start | Ensure simulator is booted and session defaults are set |
| Video file not saved | Use absolute path with `.mp4` extension |
| UI tap not working | Call `describe_ui()` to get correct coordinates/labels |
| Element not found by label | Check accessibility labels in SwiftUI code, use coordinates as fallback |
| Choppy video | Reduce `fps` to 24, add `postDelay` to interactions |

## Log Capture

```javascript
// Start capturing simulator logs
start_sim_log_cap({
    simulatorUuid: "SIMULATOR_UUID",
    bundleId: "com.example.YourApp"
})

// Stop and retrieve logs
stop_sim_log_cap({
    logSessionId: "SESSION_ID"
})

// Device logs
start_device_log_cap({
    deviceId: "DEVICE_UUID",
    bundleId: "com.example.YourApp"
})
```

## Utility Functions

```javascript
// Get bundle ID from app
get_app_bundle_id({
    appPath: "/path/to/YourApp.app"
})

// Clean build artifacts
clean_ws({
    workspacePath: "/path/to/YourApp.xcworkspace"
})

// Get app path for simulator
get_sim_app_path_name_ws({
    workspacePath: "/path/to/YourApp.xcworkspace",
    scheme: "YourApp",
    platform: "iOS Simulator",
    simulatorName: "iPhone 16"
})
```
