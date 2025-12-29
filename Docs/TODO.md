# Project 2026 – Remaining Work

Based on [prd.md](prd.md), the following items are not yet implemented.

---

## High Priority

### Goodreads Integration
- [ ] Implement OAuth sign-in flow
- [ ] Fetch "currently reading" shelf from Goodreads API
- [ ] Sync book metadata (title, author, cover, pages)
- [ ] Handle offline fallback to local data

### Today Screen Enhancements
- [ ] Add Work Balance indicator (track 9–5:30 schedule)
- [ ] Add Outdoors Reminder card

### Habits
- [ ] Build archive habits UI flow (model supports `isActive`)
- [ ] Add duration input UI for timed habits (meditation, hot tub)
- [ ] Multiple book selection when logging reading sessions

### Water Tracking
- [ ] Add manual entry field (not just quick-add buttons)
- [ ] Add water intake graph in History view

---

## Medium Priority

### UI Tests
- [ ] Navigation tests
- [ ] Completing tasks tests
- [ ] Logging water tests
- [ ] Logging reading tests
- [ ] Widget snapshot tests (if feasible)

### History Enhancements
- [ ] Water consumption graph over time
- [ ] Reading pages graph over time

---

## Low Priority / Future

### Supabase Sync (Optional)
- [ ] Set up Supabase project
- [ ] Create tables: profiles, habits, habit_logs, cleaning_tasks, cleaning_logs, water_logs, books, reading_sessions, day_summaries
- [ ] Implement Row Level Security (RLS) by user_id
- [ ] Build SupabaseSyncService
- [ ] Sync on app launch and major changes

### Analytics & Insights
- [ ] Trend analysis for habits
- [ ] Streak visualization improvements
- [ ] Weekly/monthly comparison charts

### Multi-User Support
- [ ] User authentication
- [ ] Profile switching
- [ ] Shared household cleaning tasks

---

## Completed ✅

- [x] All core data models (Goal, HabitTemplate, HabitLog, CleaningTask, etc.)
- [x] Core habits across all categories (Life, Fitness, Nutrition, Health, Work, Supplements)
- [x] Habit frequencies (daily, weekly, specific days)
- [x] Habit input types (boolean, numeric)
- [x] Cleaning rotation with recurrence patterns (daily, weekly, biweekly, monthly, custom)
- [x] Cleaning task snooze functionality
- [x] Water tracking with quick-add buttons (8oz, 16oz, 24oz, 32oz)
- [x] Reading tracker (local books, sessions, progress)
- [x] Daily score calculation (50% habits, 20% cleaning, 15% water, 15% reading)
- [x] History calendar view with day summaries
- [x] Weekly summary aggregation
- [x] ChatGPT markdown export (weekly and daily)
- [x] Theming system (Default, Minimal, Outdoors, Gym)
- [x] Home screen widgets (small and medium)
- [x] PersistenceManager with App Group support
- [x] Unit tests for recurrence, compliance, scoring, water, reading logic
- [x] Documentation comments on all structs/classes

---

*Last updated: December 29, 2025*
