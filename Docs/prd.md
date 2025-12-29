# Project 2026 – Product Requirements Document (PRD)

## 1. Vision

Project 2026 is a personal life OS that helps make 2026 your best year by:
- Turning long-term goals into a daily executable system
- Reducing decision fatigue (cleaning rotation, default habits)
- Supporting health, performance, and presence
- Keeping visibility effortless via a home screen widget
- Making reflection easy through ChatGPT review summaries
- Tracking water consumption meaningfully
- Tracking reading progress, with optional Goodreads integration

Single-user only for v1. Future-proofed for theming, analytics, & possible multi-user expansion.

---

## 2. Goals

### 2.1 High-Level Goals (Displayed in app)
- Be more present and enjoy the time I have
- Live a healthy life
- Enjoy the outdoors and Utah more

---

### 2.2 KPIs
- **Bike:** Reach 250 FTP
- **Ski:** Ski every SLC resort, ski 50 days
- **Phone:** Under 1 hour/day

KPIs are manually tracked in v1; may automate in future.

---

## 3. Processes → Habits

Each process becomes a core habit template. Core habits are hardcoded but toggleable. User may also create custom habits.

### 3.1 Core Habits — Life
- Brick phone 5–8pm
- Read a chapter a day (now powered by reading tracker)

### 3.2 Core Habits — Fitness
- Workout 6x/week
- Mobility 6x/week

### 3.3 Core Habits — Nutrition
- Drink 100oz of water a day
- Minimize processed foods
- No liquid calories
- Only 2 cups of coffee per day
- Hit 145g of protein/day

### 3.4 Core Habits — Health
- Lights out by 10pm
- Track HRV daily
- Meditate daily

### 3.5 Core Habits — Work
- Work 9–5:30
- Limit social media to 15 min/day

### 3.6 Core Habits — Supplements & Recovery
- Wake up 5:30am
- Multivitamin
- Recovery vitamin
- Anti-sickness vitamin
- 10 min in hot tub
- Daily mobility

### 3.7 Dynamic Habits
- User can add habits with:
  - Title
  - Category
  - Frequency
  - Input type (boolean, numeric, duration, note)

---

## 4. Features

---

### 4.1 Daily Checklist (Today Screen)

#### Core
- Consolidated Today dashboard:
  - Active habits
  - Water tracker
  - Today's cleaning tasks
  - Reading progress card
  - Reflection prompts
  - Work balance
  - Outdoors reminder

#### User Actions
- Check off boolean habits
- Provide values for numeric habits
- Add water
- Log reading
- Complete cleaning tasks
- Respond to reflection items

#### Computed
- Completion %
- Daily "score"
- Streak compliance signals

---

### 4.2 Habits Management
- View core habits
- Toggle on/off
- Add custom habits
- Edit custom habits
- Archive habits
- Categories labeled visually

---

### 4.3 Cleaning Rotation (Single User)

#### Functionality
- Maintains structured routine without thought load
- Library of cleaning tasks:
  - Kitchen reset
  - Floors
  - Bathrooms
  - Laundry
  - Fridge clean-out
  - Bedding
  - Car clean
  - Garage/Gear tidy

#### Task Attributes
- Recurrence
  - daily / weekly / monthly / custom
- Estimated minutes (optional)
- Active/archived

#### Behavior
- System surfaces 1–3 daily tasks
- Overdue tasks prioritized
- Snooze option
- History retained

---

### 4.4 History & Review
- Day list or calendar view
- Daily:
  - Score
  - Habits completed / total
  - Cleaning completion
- Weekly summary:
  - Averages
  - Compliance %
  - Streaks
- Button:
  - Generate ChatGPT Summary
  - Markdown export

---

### 4.5 Export for ChatGPT

Produces structured review:
- Goals
- KPIs
- Completion stats
- Cleaning performance
- Reading
- Water
- Reflection metrics
- Notes

User can copy/share into ChatGPT manually.

---

## 5. Home Screen Widget

WidgetKit powered.

### Types
- **Primary:** Medium widget
- **Optional:** Small widget

### Medium Widget Content
- "Project 2026"
- Progress ring
- X / N completed
- Highlight next important item
- Cleaning task status

### Tap
- Opens Today screen

### Data
- Reads from shared local storage
- Periodic refresh

---

## 6. Theming

### Requirements
- Clean, tasteful default
- Theming prepared for:
  - Minimal
  - Outdoors
  - Gym personality in future

### Implementation
- Theme model with:
  - primary
  - accent
  - background
  - card
  - positive
  - warning
- Stored and applied via Environment
- Only "Default" enabled in v1

---

## 7. Data Model (Core Entities)
- UserProfile
- Goal
- HabitTemplate
- HabitLog
- CleaningTask
- CleaningLog
- DaySummary
- Theme
- WaterLog / WaterEntry
- Book
- ReadingSession
- ReadingProgress
- GoodreadsAccount

---

## 8. Water Tracking (Enhanced)

### Purpose
Meaningful hydration tracking, not just checkbox.

### Requirements
- Daily target (default 100oz)
- Quick add buttons
  - +8 / +12 / +16 / etc
- Manual adjustment option
- Visual indicator:
  - progress bar or ring
- Counts as habit completed when >= target

### History
- Store daily totals
- Graph in History later

### UI Placement
- Dedicated water row on Today screen

---

## 9. Reading Tracker + Goodreads Integration

### Purpose
Enhance "Read a chapter a day" via real reading progress.

### Requirements

#### Local Reading Tracker
- Add books
- Store:
  - title
  - author
  - pages
  - cover
- Track:
  - reading sessions
  - pages read
  - minutes
  - completion %

#### Goodreads Integration
- Sign in via OAuth
- Pull:
  - currently reading shelf
  - book metadata
- Sync:
  - active reading state
- Allow manual mode if Goodreads unavailable

### UX

#### Today Screen
- Shows current book
- Progress (e.g., "35%")
- Button:
  - Log reading

#### Logging Reading
- Select book (if multiple)
- Enter:
  - pages
  - optional note

#### Failure Mode
- Works offline
- Uses last synced Goodreads state
- Falls back to local persistence

---

## 10. Supabase (Optional Sync)

### Future benefit:
- Backup
- Cross-device sync
- Expandability

### Tables:
- profiles
- habits
- habit_logs
- cleaning_tasks
- cleaning_logs
- water_logs
- books
- reading_sessions
- day_summaries

RLS by user_id

### Sync:
- App launch
- Major changes

---

## 11. Architecture

SwiftUI + MVVM

### View Models
- TodayViewModel
- HabitsViewModel
- CleaningViewModel
- WaterViewModel / Service
- ReadingViewModel / Service
- HistoryViewModel
- SettingsViewModel

### Services
- HabitService
- CleaningService
- DaySummaryService
- WaterService
- ReadingService
- GoodreadsService
- ExportService
- ThemeService
- SupabaseSyncService (optional)

---

## 12. Testing & CI

### Testing

#### Unit tests
- recurrence logic
- habit compliance logic
- daily score algorithm
- water calculations
- reading tracking correctness

#### UI tests
- Navigation
- Completing tasks
- Logging water
- Logging reading
- Widget snapshot checks (if possible)

### Artifacts
- logs
- screenshots

---

## 13. Home Screen Widget Summary
- Displays:
  - Completion %
  - Completed count
  - Highlight habit
  - Cleaning reminder
- Medium widget required
- Small widget optional

---

## 14. Success Criteria
- ≥5 days/week use
- Cleaning completion > 65%
- Visible habit streaks
- Hydration logging used daily
- Reading tracked consistently
- Widget usage high
- Reflection summaries helpful
