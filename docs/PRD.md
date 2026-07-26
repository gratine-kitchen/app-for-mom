# Product Requirements Document (PRD)
## App for Mom — Shared Date & Events App

### 1. Problem Statement
A simple, easy-to-use app for family members to see today's date prominently displayed and manage shared upcoming events. The app targets users (especially older adults) who benefit from large, clear text and a minimal interface. Multiple family members on different devices need to see and contribute to the same event list.

### 2. Target Users
- Primary: Older adults who want a clear view of today's date and upcoming family events
- Secondary: Family members who add and manage shared events

### 3. Core Features (v1)

#### 3.1. Today's Date Display
- Display today's date in a very large font (40sp bold) on the home screen
- Format: full day name, month, day, year (e.g., "Saturday, July 26, 2026")
- Centered, visually prominent with a card/container background

#### 3.2. Shared Upcoming Events
- All users see the same event list — no per-user filtering
- Events are ordered by date, nearest first
- Only future events are shown (today and later)
- Empty state message when no upcoming events exist
- Real-time updates: events appear instantly on all devices

#### 3.3. Event Creation
- Users can create new events with a title and date
- Title is required (non-empty validation)
- Date must be today or in the future (no past dates)
- Simple bottom sheet UI with a date picker

### 4. Non-Functional Requirements

| Requirement | Detail |
|---|---|
| Platform | iOS (iPhone + iPad) |
| Framework | Flutter (latest stable) |
| Backend | Firebase Firestore |
| Real-time sync | Yes — Firestore streams |
| Offline support | Firestore built-in offline persistence |
| Performance | Fast load, responsive UI |
| Accessibility | Large fonts, high contrast, minimal cognitive load |
| Multi-device | Multiple users on different devices see the same data |

### 5. Out of Scope (v1)
- User authentication / accounts
- Event deletion UI (backend method exists)
- Event editing
- Recurring events / reminders
- Dark mode
- Push notifications
- iPad-specific split-view layouts

### 6. Success Metrics
- User can read today's date at a glance
- Event creation takes < 10 seconds
- New events appear on another device within 2 seconds
- Zero crashes during normal usage
