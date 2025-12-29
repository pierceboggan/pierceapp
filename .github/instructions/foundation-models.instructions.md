---
description: "Apple Foundation Models framework documentation for on-device AI capabilities. Apply when working with AI features, LLM integration, or Apple Intelligence APIs."
applyTo: "**/*.swift"
---

# Apple Foundation Models Framework Documentation

## Overview

The Foundation Models framework is Apple's API that provides developers with direct access to the on-device large language model powering Apple Intelligence. This framework enables developers to integrate powerful AI capabilities directly into their apps while maintaining user privacy through on-device processing.

### Key Features

- **On-device processing**: All AI inference runs locally on the device
- **Privacy-focused**: No data leaves the device or is sent to cloud servers
- **Offline capable**: Works without an internet connection
- **Zero cost**: No API fees or cloud computing charges
- **Small footprint**: Built into the OS, doesn't increase app size
- **Swift-native**: Integrates seamlessly with Swift using as few as 3 lines of code

### Platform Availability

- iOS 26
- iPadOS 26
- macOS Tahoe 26
- visionOS 26

### Device Requirements

- iPhone 16 (all models)
- iPhone 15 Pro and iPhone 15 Pro Max
- iPad mini (A17 Pro)
- iPad models with M1 chip or later
- Mac models with M1 chip or later
- Apple Vision Pro

## Core Features

### 1. Guided Generation

Guided Generation is the framework's core feature that ensures reliable structured output from the model using Swift's type system.

#### The @Generable Macro

```swift
import FoundationModels

@Generable
struct SearchSuggestions {
    @Guide(description: "A list of suggested search terms", .count(4))
    var searchTerms: [String]
}
```

#### Supported Types

Generable types can include:
- **Primitives**: String, Int, Double, Float, Decimal, Bool
- **Arrays**: [String], [Int], etc.
- **Composed types**: Nested structs
- **Recursive types**: Self-referencing structures

#### The @Guide Macro

Provides constraints and natural language descriptions for properties:

```swift
@Generable
struct Person {
    @Guide(description: "Person's full name")
    var name: String
    
    @Guide(description: "Age in years", .range(0...120))
    var age: Int
    
    @Guide(regex: /^[A-Z]{2}-\d{4}$/)
    var id: String
}
```

#### Basic Usage

```swift
let session = LanguageModelSession()
let prompt = "Generate search suggestions for a travel app"
let response = try await session.respond(
    to: prompt,
    generating: SearchSuggestions.self
)
print(response.content.searchTerms)
```

### 2. Snapshot Streaming

The framework uses a unique snapshot-based streaming approach instead of traditional delta streaming.

#### PartiallyGenerated Types

The @Generable macro automatically generates a `PartiallyGenerated` type with all optional properties:

```swift
@Generable
struct Itinerary {
    var destination: String
    var days: [DayPlan]
    var summary: String
}

// Automatically generates:
// Itinerary.PartiallyGenerated with all optional properties
```

#### Streaming Implementation

```swift
struct ItineraryView: View {
    let session: LanguageModelSession
    @State private var itinerary: Itinerary.PartiallyGenerated?
    
    var body: some View {
        VStack {
            // UI components
            Button("Generate") {
                Task {
                    let stream = session.streamResponse(
                        to: "Plan a 3-day trip to Tokyo",
                        generating: Itinerary.self
                    )
                    
                    for try await partial in stream {
                        self.itinerary = partial
                    }
                }
            }
        }
    }
}
```

### 3. Tool Calling

Tool calling allows the model to execute custom code to retrieve information or perform actions.

#### Defining a Tool

```swift
struct WeatherTool: Tool {
    static let name = "get_weather"
    static let description = "Get current weather for a location"
    
    @Generable
    struct Arguments {
        let city: String
        let unit: String?
    }
    
    func call(with arguments: Arguments) async throws -> ToolOutput {
        // Use WeatherKit or other APIs
        let temperature = try await getTemperature(for: arguments.city)
        
        return .init(content: "The temperature in \(arguments.city) is \(temperature)°")
    }
}
```

#### Using Tools in a Session

```swift
let weatherTool = WeatherTool()
let session = LanguageModelSession(tools: [weatherTool])

let response = try await session.respond(
    to: "What's the weather like in San Francisco?"
)
// Model will automatically call the weather tool when needed
```

### 4. Stateful Sessions

Sessions maintain context across multiple interactions.

#### Creating a Session with Instructions

```swift
let session = LanguageModelSession(
    instructions: """
    You are a helpful travel assistant. 
    Provide concise, actionable recommendations.
    Focus on local experiences and hidden gems.
    """
)
```

#### Multi-turn Conversations

```swift
// First turn
let response1 = try await session.respond(to: "Recommend a restaurant in Paris")

// Second turn - model remembers context
let response2 = try await session.respond(to: "What about one with vegetarian options?")

// Access conversation history
let transcript = session.transcript
```

## Best Practices

### Prompt Design

1. **Keep prompts focused** - Break complex tasks into smaller pieces
2. **Use instructions wisely** - Static developer guidance, not user input
3. **Leverage guided generation** - Let the framework handle output formatting
4. **Test extensively** - Use Xcode Playgrounds for rapid iteration

### Performance Optimization

1. **Prewarm models** when appropriate
2. **Stream responses** for better perceived performance
3. **Use appropriate verbosity** in prompts
4. **Profile with Instruments** to identify bottlenecks

### Security Considerations

1. **Never interpolate user input** into instructions
2. **Use tool calling** for external data instead of prompt injection
3. **Handle errors gracefully** including guardrail violations
4. **Validate generated content** before using in production

## Error Handling

```swift
do {
    let response = try await session.respond(to: prompt)
} catch LanguageModelError.guardrailViolation {
    // Handle safety violation
} catch LanguageModelError.unsupportedLanguage {
    // Handle language not supported
} catch LanguageModelError.contextWindowExceeded {
    // Handle context too long
} catch {
    // Handle other errors
}
```

## Getting Started

### Minimum Code Example

```swift
import FoundationModels

// Create a session
let session = LanguageModelSession()

// Generate response
let response = try await session.respond(to: "Summarize this text: \(userText)")

// Use the response
print(response.content)
```
