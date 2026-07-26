# Technical Architecture Document
## App for Mom — Shared Date & Events App

**Last Updated**: 2026-07-26

### 1. Tech Stack

| Layer | Technology | Version |
|---|---|---|
| Framework | Flutter | Latest stable |
| Language | Dart | 3.x |
| Backend | Firebase Firestore | Latest |
| State Management | StreamBuilder (no external package) | Built-in |
| Date Formatting | `intl` package | Latest |
| Testing | `flutter_test` + `fake_cloud_firestore` | Latest |

### 2. Architecture Overview

```
┌─────────────────────────────────────────┐
│              UI Layer                    │
│  ┌─────────────┐  ┌──────────────────┐  │
│  │ HomeScreen   │  │ AddEventSheet    │  │
│  │ (date + list)│  │ (bottom sheet)   │  │
│  └──────┬───────┘  └────────┬─────────┘  │
│         │                   │            │
├─────────┼───────────────────┼────────────┤
│         │    Service Layer  │            │
│         └───────┬───────────┘            │
│          ┌──────┴──────┐                 │
│          │FirestoreSvc │ (interface)     │
│          │FirestoreImpl │                 │
│          └──────┬──────┘                 │
├─────────────────┼────────────────────────┤
│         ┌──────┴──────┐                 │
│         │  Firestore   │  (cloud)        │
│         └─────────────┘                 │
└─────────────────────────────────────────┘
```

### 3. Data Model

#### Firestore Collection: `events`
```
events/
  {auto-id}/
    title:     string   (required, non-empty)
    date:      Timestamp (required, >= today)
    createdAt: Timestamp (auto, server or client time)
```

#### Dart Model: `Event`
```dart
class Event {
  final String id;
  final String title;
  final DateTime date;
  final DateTime createdAt;
}
```

### 4. Data Flow

```
1. App starts → Firebase.init() → HomeScreen loads
2. HomeScreen → StreamBuilder subscribes to getUpcomingEvents()
3. Firestore streams events where date >= today, ordered by date ASC
4. User taps FAB → AddEventSheet opens
5. User fills title + picks date → taps Save
6. AddEventSheet → FirestoreService.addEvent() → Firestore write
7. Firestore write triggers stream update → HomeScreen rebuilds with new event
8. All other devices with active streams receive the update automatically
```

### 5. Screen Hierarchy

```
MaterialApp
  └── HomeScreen
        ├── DateDisplay (large text widget)
        ├── EventList (StreamBuilder → ListView)
        │     └── EventCard (title + date)
        └── FAB → showModalBottomSheet
              └── AddEventSheet
                    ├── TextFormField (title)
                    └── DatePicker trigger
```

### 6. Dependency Injection

Simple constructor injection — no DI framework needed:

```
main.dart creates FirestoreServiceImpl
  → passes to HomeScreen(firestoreService)
    → passes to AddEventSheet(firestoreService) when FAB tapped
```

### 7. Testing Strategy

| Test Type | Tool | Scope |
|---|---|---|
| Unit tests | `flutter_test` + `fake_cloud_firestore` | Event model, FirestoreService |
| Widget tests | `flutter_test` | HomeScreen rendering, AddEventSheet validation |
| Integration | Manual on simulator | Multi-device sync, real Firestore |

### 8. Security (Firestore Rules)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /events/{eventId} {
      allow read, write: if true;  // No auth — open access for shared family use
    }
  }
}
```

### 9. Directory Structure

```
app_for_mom/
├── docs/
│   ├── PRD.md
│   └── ARCHITECTURE.md
├── scripts/
│   ├── startup.sh
│   └── teardown.sh
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── models/
│   │   └── event.dart
│   ├── services/
│   │   └── firestore_service.dart
│   └── screens/
│       ├── home_screen.dart
│       └── add_event_sheet.dart
├── test/
│   ├── models/
│   │   └── event_test.dart
│   ├── services/
│   │   └── firestore_service_test.dart
│   └── screens/
│       ├── home_screen_test.dart
│       └── add_event_sheet_test.dart
├── pubspec.yaml
├── firestore.rules
└── ios/
    └── Runner/
        └── GoogleService-Info.plist
```
