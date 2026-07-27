# Onboarding Guide — App for Mom

**Last Updated**: 2026-07-27

Welcome to the team! This guide will get you from zero to committing code as quickly as possible. Everything is Mac-first — if you need Windows/Linux, we'll tackle that separately.

---

## 1. The App in 60 Seconds

| | |
|---|---|
| **What** | A shared family calendar app. Shows today's date in large text + a real-time shared event list. |
| **Users** | Older adults (big fonts, minimal UI) + their family (add/manage events). |
| **Tech** | Flutter (Dart), Firebase Firestore, no auth. |
| **Platforms** | iOS (primary), Android (coming soon). |
| **Repo** | GitHub — ask the team lead for access. |

📖 After setup, read these in order:
1. [`docs/PRD.md`](./PRD.md) — what we're building and why
2. [`docs/ARCHITECTURE.md`](./ARCHITECTURE.md) — how it's built
3. [`docs/DEPLOYMENT.md`](./DEPLOYMENT.md) — how to ship it

---

## 2. Environment Setup (macOS)

### 2.1 Prerequisites

Install these in order. Skip any you already have.

#### Flutter SDK
```bash
# Download from https://docs.flutter.dev/get-started/install/macos
# Or use Homebrew:
brew install --cask flutter
```

Verify:
```bash
flutter doctor
```
Fix any issues it reports before proceeding. At minimum you need:
- ✅ Flutter SDK
- ✅ Xcode (for iOS simulator)
- ✅ Android Studio (for Android emulator — optional but recommended)
- ✅ CocoaPods

#### Xcode
```bash
# Install from the Mac App Store, then:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch   # accept the license
```

Open Xcode once → Settings → Platforms → download an iOS Simulator runtime.

#### CocoaPods
```bash
brew install cocoapods
```

#### Android Studio (optional, for Android)
```bash
brew install --cask android-studio
```
Open Android Studio once → More Actions → SDK Manager → install an Android SDK platform + emulator.

#### Firebase CLI
```bash
brew install firebase-cli
firebase login
```

#### FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2.2 Clone & Install

```bash
git clone <repo-url> app-for-mom
cd app-for-mom
flutter pub get
```

### 2.3 Firebase Access

Ask the team lead to add your Google account to the **Firebase project** `app-for-mom-d54a2` with **Editor** (or Owner) role.

Then pull the latest FlutterFire config:
```bash
flutterfire configure --project=app-for-mom-d54a2 --platforms=ios,android
```

This updates:
- `lib/firebase_options.dart` — platform-specific Firebase config
- `ios/Runner/GoogleService-Info.plist` — iOS Firebase config
- `android/app/google-services.json` — Android Firebase config (if Android platform exists)

### 2.4 Verify Everything Works

```bash
./scripts/startup.sh
```

This script will:
1. Check prerequisites (Flutter, Xcode, CocoaPods)
2. Install dependencies (`flutter pub get`)
3. Boot the iOS Simulator
4. Launch the app (`flutter run`)

> ⚠️ The first build can take **10–20 minutes** — Firebase has many native dependencies that need to compile. Subsequent builds are fast.

---

## 3. Project Tour

```
app-for-mom/
├── docs/                          # ← You are here
│   ├── PRD.md                     # Product requirements
│   ├── ARCHITECTURE.md            # Technical architecture
│   ├── DEPLOYMENT.md              # Build & distribute
│   └── ONBOARDING.md              # This file
│
├── lib/                           # ← All app code lives here
│   ├── main.dart                  # Entry point, Firebase init, MaterialApp
│   ├── firebase_options.dart      # Platform Firebase config (auto-generated)
│   ├── models/
│   │   └── event.dart             # Event data model + Firestore serialization
│   ├── services/
│   │   ├── firestore_service.dart  # Abstract interface
│   │   └── firestore_service_impl.dart  # Real Firestore implementation
│   └── screens/
│       ├── home_screen.dart        # Main screen: date + event list
│       └── add_event_sheet.dart    # Bottom sheet: create new event
│
├── test/                          # ← All tests live here
│   ├── models/
│   │   └── event_test.dart
│   ├── services/
│   │   └── firestore_service_test.dart
│   └── screens/
│       ├── home_screen_test.dart
│       └── add_event_sheet_test.dart
│
├── ios/                           # iOS native project
├── android/                       # Android native project (if added)
├── scripts/
│   ├── startup.sh                 # One-command dev environment launch
│   └── teardown.sh               # Cleanup
├── firestore.rules                # Firestore security rules
├── firestore.indexes.json         # Firestore composite indexes
└── pubspec.yaml                   # Dart dependencies
```

---

## 4. Key Architecture Decisions

### No state management package
We use Flutter's built-in `StreamBuilder` directly. No Provider, Riverpod, or Bloc. This keeps things simple for a small app. If we grow significantly, revisit this.

### Interface-based service layer
`FirestoreService` is an abstract interface. `FirestoreServiceImpl` is the real implementation. This pattern makes testing easy — tests inject `FakeFirebaseFirestore` instead of hitting real Firestore.

### Constructor injection (no DI framework)
`main.dart` creates the service and passes it down. Screens receive it via constructor. Simple and explicit.

### No authentication
The app has no login. Firestore rules allow open read/write. This is intentional for v1 — the target users shouldn't need to sign in. If the app grows beyond family use, add auth.

### iOS-first, Android-second
The iOS platform is fully configured. Android support requires running `flutter create --platforms=android .` and `flutterfire configure` — see `DEPLOYMENT.md`.

---

## 5. Development Workflow

### 5.1 Daily Start
```bash
./scripts/startup.sh
```

### 5.2 Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/models/event_test.dart

# With coverage
flutter test --coverage
```

### 5.3 Before Committing
```bash
# 1. Run all tests
flutter test

# 2. Check for analysis issues
flutter analyze

# 3. If you changed Firestore rules, test them locally (optional)
# firebase emulators:start --only firestore
```

### 5.4 Commit Convention
- `feat:` — new feature (e.g., `feat: add event deletion UI`)
- `fix:` — bug fix (e.g., `fix: date picker allows past dates`)
- `test:` — test changes only
- `docs:` — documentation only
- `refactor:` — code change that's not a fix or feature

---

## 6. AI Copilot Onboarding

If you're using GitHub Copilot or a similar AI coding agent in VS Code, paste these prompts **in order** to get it up to speed quickly. The AI will read the codebase and build context.

### Prompt 1 — Project Overview

```
Please read docs/PRD.md, docs/ARCHITECTURE.md, docs/DEPLOYMENT.md, and docs/ONBOARDING.md in full. Then summarize the app's purpose, tech stack, and architecture in 5 bullet points. Confirm you understand the codebase by listing every Dart file under lib/ and its role.
```

### Prompt 2 — Codebase Deep Dive

```
Read every file under lib/ and test/. For each file, explain: (1) its purpose, (2) its key classes/methods, (3) how it connects to other files. Also read pubspec.yaml and list every dependency with its purpose.
```

### Prompt 3 — Firestore Understanding

```
Read firestore.rules, firestore.indexes.json, and lib/services/firestore_service.dart + firestore_service_impl.dart. Explain the data model, the queries being used, the security posture, and what composite indexes are needed.
```

### Prompt 4 — Verify Readiness

```
I'm a new team member on this project. Ask me 3 questions to verify I understand the codebase well enough to start contributing. Then suggest a good first task.
```

---

## 7. Common Tasks & Where to Start

| Task | Files to Touch |
|---|---|
| Add event editing UI | `lib/screens/add_event_sheet.dart` (reuse or create `edit_event_sheet.dart`), `lib/services/firestore_service.dart` (add `updateEvent`) |
| Add event deletion button | `lib/screens/home_screen.dart` (add delete icon to event cards), `lib/services/firestore_service.dart` (`deleteEvent` already exists) |
| Add dark mode | `lib/main.dart` (change `ThemeData`), add `Brightness.dark` variant |
| Add Android support | Run platform commands (see `DEPLOYMENT.md`), no code changes needed |
| Add user authentication | New service, new screen, update Firestore rules |
| Add push notifications | Firebase Cloud Messaging setup + platform config |
| Add event categories/colors | Update `lib/models/event.dart`, update Firestore schema |

---

## 8. Troubleshooting

### `flutter doctor` shows issues
Run the commands it suggests. Common fixes:
```bash
flutter doctor --android-licenses   # accept Android licenses
sudo gem install cocoapods          # if CocoaPods is missing
```

### iOS build stuck on "Running Xcode build..."
Normal for first build. Wait 10–20 minutes. Subsequent builds are fast.

### "Firebase options not configured for this platform"
Run `flutterfire configure --project=app-for-mom-d54a2 --platforms=ios,android`

### Tests fail with Firestore-related errors
Ensure `fake_cloud_firestore` is in `dev_dependencies` in `pubspec.yaml`. Run `flutter pub get`.

### Can't connect to Firestore
Check that your Google account has been added to the Firebase project `app-for-mom-d54a2`.

---

## 9. Team Contacts

| Role | Who | Contact |
|---|---|---|
| Project Lead | (ask) | (ask) |
| Firebase Admin | (ask) | (ask) |
| Apple Developer Account | (ask) | (ask) |

---

## 10. Quick Reference

```bash
# Start developing
./scripts/startup.sh

# Run all tests
flutter test

# Run specific test
flutter test test/models/event_test.dart

# Static analysis
flutter analyze

# Build iOS release
flutter build ios --release

# Build Android APK
flutter build apk --release

# Update Firebase config
flutterfire configure --project=app-for-mom-d54a2 --platforms=ios,android

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Clean build artifacts
flutter clean && flutter pub get
```
