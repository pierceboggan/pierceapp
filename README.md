# Project 2026

A personal life OS to make 2026 your best year - built with SwiftUI for iOS.

## Overview

Project 2026 is a comprehensive life management app that helps you:
- Turn long-term goals into a daily executable system
- Reduce decision fatigue with automated cleaning rotation and default habits
- Support health, performance, and presence
- Keep visibility effortless via home screen widgets
- Make reflection easy through ChatGPT review summaries
- Track water consumption meaningfully
- Track reading progress with optional Goodreads integration

## Features

### Daily Dashboard (Today Screen)
- Consolidated view of active habits, water intake, cleaning tasks, and reading progress
- Real-time completion tracking with daily score
- Quick-add water buttons (8oz, 12oz, 16oz, 20oz, custom)
- Reading progress cards with log reading button

### Enhanced Water Tracking
- Daily target (default 100oz)
- Quick add buttons for common amounts
- Manual adjustment option
- Visual progress indicator
- Counts toward daily habit completion

### Reading Tracker + Goodreads Integration
- Add and track books locally
- Log reading sessions with pages read and optional notes
- Track progress percentage
- Optional Goodreads OAuth integration to sync currently reading shelf
- Works offline with local persistence

### Habits Management
- Pre-configured core habits across categories:
  - Life, Fitness, Nutrition, Health, Work, Supplements & Recovery
- Create custom habits with:
  - Title, Category, Frequency
  - Input type (boolean, numeric, duration, note)
- Toggle habits on/off
- Track completion daily

### Cleaning Rotation
- Pre-configured cleaning tasks (kitchen, floors, bathrooms, laundry, etc.)
- Automatic scheduling (daily/weekly/monthly/custom)
- Surfaces 1-3 daily tasks
- Prioritizes overdue tasks
- Track completion history

### History & Review
- Daily summaries with score and completion stats
- Weekly summary with averages and compliance percentage
- Calendar view of past performance
- Export to ChatGPT for reflection and analysis

### Settings
- View high-level goals and KPIs
- Adjust water tracking target
- Connect/disconnect Goodreads
- Theme selection (Default theme in v1)

## Architecture

### Tech Stack
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults (local storage)
- **Deployment Target**: iOS 16.0+

### Project Structure
```
Project2026/
├── Models/              # Data models (Codable structs)
├── Services/            # Business logic and data management
├── ViewModels/          # View state management
├── Views/              # SwiftUI views
└── Resources/          # Assets and resources
```

### Core Services
- `HabitService` - Manage habits and habit logs
- `CleaningService` - Manage cleaning tasks and scheduling
- `WaterService` - Track daily water consumption
- `ReadingService` - Manage books and reading sessions
- `GoodreadsService` - Handle Goodreads OAuth and sync
- `DaySummaryService` - Calculate daily scores and summaries
- `ExportService` - Generate ChatGPT-compatible exports
- `ThemeService` - Manage app theming

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- macOS 13.0+ (for development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/pierceboggan/pierceapp.git
cd pierceapp
```

2. Open the project in Xcode:
```bash
open Project2026/Project2026.xcodeproj
```

3. Select your target device/simulator

4. Build and run (⌘R)

## Usage

### First Launch
On first launch, the app will:
- Create 20 pre-configured core habits
- Set up 8 default cleaning tasks
- Initialize water tracking with 100oz target
- Set default theme

### Daily Workflow
1. Open the app to see Today screen with your daily dashboard
2. Check off completed habits
3. Log water intake throughout the day
4. Complete cleaning tasks as they appear
5. Log reading sessions for books you're reading
6. Check your daily score and progress

### Weekly Review
1. Navigate to History tab
2. Review your weekly summary
3. Tap export button to generate ChatGPT summary
4. Copy and share with ChatGPT for reflection

## Documentation

See [Docs/prd.md](Docs/prd.md) for the complete Product Requirements Document.

## Roadmap

### v1.0 (Current)
- ✅ Core habits system
- ✅ Enhanced water tracking
- ✅ Reading tracker with local storage
- ✅ Goodreads integration (OAuth placeholder)
- ✅ Cleaning rotation
- ✅ Daily summaries and scoring
- ✅ ChatGPT export
- ✅ Basic theming support

### Future Enhancements
- Home screen widgets (WidgetKit)
- Additional themes (Minimal, Outdoors, Gym)
- Supabase backend for sync and backup
- Advanced analytics and charts
- Automated KPI tracking
- Multi-user support

## Testing

### Unit Tests
Run unit tests for:
- Recurrence logic
- Habit compliance calculations
- Daily score algorithm
- Water calculations
- Reading tracking correctness

```bash
# Run tests in Xcode
⌘U
```

### UI Tests
Test navigation, task completion, and data entry flows.

## Contributing

This is a personal project, but feedback and suggestions are welcome!

## License

Copyright © 2025 Pierce Boggan. All rights reserved.

## Contact

Pierce Boggan - [@pierceboggan](https://github.com/pierceboggan)
