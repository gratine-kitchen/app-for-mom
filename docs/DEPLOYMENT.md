# Deployment Guide — App for Mom

**Last Updated**: 2026-07-27

This document covers how to set up, build, and distribute the app to family members on both iOS and Android.

---

## Project Overview

| Detail | Value |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Firebase Firestore |
| Firebase Project ID | `app-for-mom-d54a2` |
| iOS Bundle ID | `com.appformom.appForMom` |
| Auth | None (open read/write — family-only) |

---

## 1. Prerequisites

### For iOS
- macOS with Xcode installed
- [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)
- CocoaPods (`brew install cocoapods`)

### For Android
- Android Studio (for SDK & emulator)
- Java JDK 17+
- (Optional) Google Play Developer account ($25 one-time)

### For Both
- Flutter SDK installed
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

---

## 2. Firebase Setup (One-Time)

These steps only need to be done once per platform.

### 2.1 Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

The rules in `firestore.rules` allow open read/write — suitable for family-only use with no authentication.

### 2.2 Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

If a composite index is needed for the `events` collection query, Firestore will prompt you on first run with a link to auto-create it.

---

## 3. iOS Setup & Deployment

### 3.1 Initial Setup

No additional setup needed — the iOS platform is already configured with Firebase.

### 3.2 Run on Simulator (Development)

```bash
./scripts/startup.sh
```

Or manually:

```bash
flutter pub get
open -a Simulator
flutter run
```

### 3.3 Distribute via TestFlight (Recommended)

TestFlight is the easiest way to share with family. They get automatic updates and don't need to connect to your computer.

**Step 1 — Enroll in Apple Developer Program**
- Go to [developer.apple.com/programs](https://developer.apple.com/programs/)
- Enroll ($99/year)
- Your account must be the Account Holder or Admin in App Store Connect

**Step 2 — Build the Archive**
```bash
flutter build ios --release
```

Then in Xcode:
1. Open `ios/Runner.xcworkspace` (not `.xcodeproj`)
2. Select **Product → Archive**
3. Wait for the archive to complete

**Step 3 — Upload to App Store Connect**
- In the Xcode Organizer window, select the archive
- Click **Distribute App → App Store Connect → Upload**
- Follow the prompts

**Step 4 — Add Testers in TestFlight**
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app → **TestFlight** tab
3. Under **Internal Testing** (or External Testing), add testers by their Apple ID email
4. Family members receive an email invite
5. They install the **TestFlight** app from the App Store, then install your app from within TestFlight

**Step 5 — Updates**
- Each time you build and upload a new archive, testers automatically get the update

---

## 4. Android Setup & Deployment

### 4.1 Initial Setup

Create the Android platform directory and register with Firebase:

```bash
# Generate the android/ directory
flutter create --platforms=android .

# Register Android app in Firebase and generate google-services.json
flutterfire configure --project=app-for-mom-d54a2 --platforms=android
```

Verify `lib/firebase_options.dart` now includes an Android entry:
```dart
case TargetPlatform.android:
  return android;  // ← this should now exist
```

### 4.2 Run on Emulator (Development)

```bash
flutter emulators --launch <emulator_id>
flutter run
```

Or create a new emulator in Android Studio:
- **Tools → Device Manager → Create Device**
- Choose a Pixel device with a recent API level
- Launch and run `flutter run`

### 4.3 Distribute via Direct APK (Easiest — Free)

No store, no account needed. Ideal for small family groups.

**Build the APK:**
```bash
flutter build apk --release
```

The APK is generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Share with family:**
- Send the `.apk` file via WhatsApp, email, Google Drive, etc.
- Recipients need to enable **Settings → Security → Install unknown apps** for the app they use to open the file
- They tap the APK and install it

**Note:** Direct APKs don't auto-update. You'll need to send a new APK when you make changes.

### 4.4 Distribute via Google Play Store (Polished — $25 one-time)

Best if you want auto-updates and a professional feel.

1. Register at [play.google.com/console](https://play.google.com/console) ($25 one-time fee)
2. Create a new app
3. Build the App Bundle:
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`
4. Upload the `.aab` to Google Play Console
5. Fill in store listing (name, description, screenshots)
6. Set up **Internal Testing** track — add family members' Google emails
7. They get a Play Store link and install like any other app

### 4.5 Distribute via Firebase App Distribution (Free)

A middle ground — free, no store, but managed through Firebase.

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <firebase-android-app-id> \
  --release-notes "Latest build" \
  --groups "family"
```

Testers get an email invite to install. They'll need to enable "Install unknown apps" the first time.

---

## 5. Quick Reference — Build Commands

| Platform | Command | Output |
|---|---|---|
| iOS dev | `flutter run` | Runs on simulator/device |
| iOS release | `flutter build ios --release` | Xcode archive |
| Android dev | `flutter run` | Runs on emulator/device |
| Android APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android Bundle | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |

---

## 6. Family Member Onboarding Checklist

### iOS Family Members
- [ ] You have an Apple Developer account
- [ ] App is uploaded to TestFlight
- [ ] Their Apple ID email is added as a tester
- [ ] They installed TestFlight from the App Store
- [ ] They accepted the TestFlight invite and installed the app

### Android Family Members
- [ ] Android platform is created (`flutter create --platforms=android .`)
- [ ] Firebase Android app is registered (`flutterfire configure`)
- [ ] APK is built and shared, OR app is on Google Play / Firebase Distribution
- [ ] They enabled "Install unknown apps" (APK method only)
- [ ] They installed and opened the app

---

## 7. Troubleshooting

### iOS Build Takes Forever
The first Xcode build with Firebase dependencies can take 10–20 minutes. Subsequent builds are much faster due to caching. Just wait.

### "Firebase options not configured for this platform"
Run `flutterfire configure` for the missing platform.

### Android APK Won't Install
Make sure the recipient has enabled **Install unknown apps** for the app they're using to open the APK (e.g., Files, Chrome, WhatsApp).

### Firestore "Missing Index" Error
Click the link in the error message to auto-create the required composite index, or run:
```bash
firebase deploy --only firestore:indexes
```