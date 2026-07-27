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

## 3. Web Setup & Deployment

The app supports running in a web browser (Chrome recommended). This is useful for quick testing or for family members who prefer using a computer.

On web, the app shows a **passcode gate** before the home screen (unlike native apps which skip this gate).

### 3.1 Initial Setup

No additional setup needed — the web platform is already configured. The `web/` directory contains `index.html` and the Firebase web configuration is embedded via `lib/firebase_options.dart`.

### 3.2 Run Locally (Development)

```bash
flutter pub get
flutter run -d chrome
```

Or use the startup script which detects the available platform:

```bash
./scripts/startup.sh
```

This launches the app in Chrome with hot-reload enabled. Make code changes and save — the browser refreshes automatically.

### 3.3 Build for Production

```bash
flutter build web --release
```

The output is generated at `build/web/`. You can serve it locally to test:

```bash
cd build/web
python3 -m http.server 8000
```

Then open http://localhost:8000 in a browser.

### 3.4 Deploy via Firebase Hosting (Recommended)

Firebase Hosting is free, fast, and provides HTTPS by default.

**One-time setup:**

```bash
firebase init hosting
```

- Select **Use an existing project** → `app-for-mom-d54a2`
- Set `build/web` as the public directory
- Configure as a single-page app: **Yes** (so Flutter's routing works)
- Overwrite `index.html`: **No**

**Deploy:**

```bash
flutter build web --release
firebase deploy --only hosting
```

After deployment, Firebase prints a URL like:
```
https://app-for-mom-d54a2.web.app
```

Share this URL with family members — they can open it in any browser on their computer or tablet.

**Re-deploy after updates:**

```bash
flutter build web --release && firebase deploy --only hosting
```

### 3.5 Browser Compatibility

| Browser | Status |
|---|---|
| Chrome | ✅ Fully supported |
| Edge | ✅ Fully supported |
| Safari | ✅ Supported |
| Firefox | ✅ Supported |
| Mobile browsers | ⚠️ Layout may vary; native apps recommended for phones |

**Note for tablets:** Family members using iPads or Android tablets can either install the native app or use the web version in their tablet's browser.

---

## 4. iOS Setup & Deployment

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

## 5. Android Setup & Deployment

### 5.1 Initial Setup

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

### 5.2 Run on Emulator (Development)

```bash
flutter emulators --launch <emulator_id>
flutter run
```

Or create a new emulator in Android Studio:
- **Tools → Device Manager → Create Device**
- Choose a Pixel device with a recent API level
- Launch and run `flutter run`

### 5.3 Distribute via Direct APK (Easiest — Free)

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

### 5.4 Distribute via Google Play Store (Polished — $25 one-time)

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

### 5.5 Distribute via Firebase App Distribution (Free)

A middle ground — free, no store, but managed through Firebase.

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <firebase-android-app-id> \
  --release-notes "Latest build" \
  --groups "family"
```

Testers get an email invite to install. They'll need to enable "Install unknown apps" the first time.

---

## 6. Quick Reference — Build Commands

| Platform | Command | Output |
|---|---|---|
| Web dev | `flutter run -d chrome` | Runs in Chrome with hot-reload |
| Web release | `flutter build web --release` | `build/web/` directory |
| iOS dev | `flutter run` | Runs on simulator/device |
| iOS release | `flutter build ios --release` | Xcode archive |
| Android dev | `flutter run` | Runs on emulator/device |
| Android APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android Bundle | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |

---

## 7. Family Member Onboarding Checklist

### Web Family Members
- [ ] App is deployed to Firebase Hosting
- [ ] Share the `.web.app` URL with family
- [ ] They open the URL in Chrome (or any modern browser)
- [ ] They enter the family passcode to access the home screen

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

## 8. Troubleshooting

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