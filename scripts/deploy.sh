#!/bin/bash
# =============================================================================
# Deploy Script — App for Mom
# Builds and deploys the app for the requested platform(s):
#   web       Firebase Hosting
#   android   Release APK
#   ios       iOS archive (Xcode)
#   all       All of the above
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# ---- Defaults ----
PASSCODE="family2026"
SKIP_TESTS=false
DRY_RUN=false
PLATFORM=""
DEPLOY_FIREBASE=false

# ---- Usage ----
usage() {
    cat <<EOF

Usage: $0 <platform> [options]

Platforms:
  web         Build web release and deploy to Firebase Hosting
  android     Build Android release APK
  ios         Build iOS release (Xcode archive step)
  all         Build and deploy all platforms

Options:
  --passcode VALUE   Custom passcode for web gate (default: $PASSCODE)
  --skip-tests       Skip running tests before build
  --deploy           For web: also deploy to Firebase Hosting (requires firebase CLI)
  --dry-run          Show what would be done without building

Examples:
  $0 web --deploy
  $0 android --skip-tests
  $0 all --passcode mySecret2026
  $0 web --dry-run

EOF
    exit 0
}

# ---- Parse args ----
while [[ $# -gt 0 ]]; do
    case "$1" in
        web|android|ios|all)
            PLATFORM="$1"
            shift
            ;;
        --passcode)
            PASSCODE="$2"
            shift 2
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --deploy)
            DEPLOY_FIREBASE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            usage
            ;;
    esac
done

if [ -z "$PLATFORM" ]; then
    echo "ERROR: No platform specified."
    usage
fi

# ---- Banner ----
echo "=============================================="
echo " App for Mom — Deploy"
echo "=============================================="
echo " Platform:   $PLATFORM"
echo " Passcode:   $PASSCODE"
echo " Skip tests: $SKIP_TESTS"
echo " Dry run:    $DRY_RUN"
echo "=============================================="

# ---- Helper: check command ----
require_cmd() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 not found. $2"
        exit 1
    fi
}

# ---- Check prerequisites ----
echo ""
echo "[0/4] Checking prerequisites..."

require_cmd flutter \
    "Install Flutter SDK: https://docs.flutter.dev/get-started/install"
echo "  ✓ Flutter SDK: $(flutter --version 2>/dev/null | head -1 || echo 'unknown')"

cd "$PROJECT_DIR"

# ---- Update passcode if specified ----
PASSCODE_FILE="$PROJECT_DIR/lib/screens/passcode_screen.dart"

update_passcode() {
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would update passcode in passcode_screen.dart"
        return
    fi
    # Replace the _familyPasscode constant value
    if [ -f "$PASSCODE_FILE" ]; then
        sed -i '' "s/const _familyPasscode = '[^']*';/const _familyPasscode = '$PASSCODE';/" "$PASSCODE_FILE"
        echo "  ✓ Passcode updated to: $PASSCODE"
    else
        echo "  ⚠ passcode_screen.dart not found — skipping passcode update"
    fi
}

# ---- Run tests ----
run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        echo ""
        echo "[1/4] Skipping tests (--skip-tests)."
        return
    fi

    echo ""
    echo "[1/4] Running tests..."
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would run: flutter test"
        return
    fi

    if ! flutter test; then
        echo "ERROR: Tests failed. Fix errors or use --skip-tests to bypass."
        exit 1
    fi
    echo "  ✓ All tests passed"
}

# ---- Build & Deploy: Web ----
deploy_web() {
    echo ""
    echo "--- Web Deployment ---"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would run: flutter build web --release"
        if [ "$DEPLOY_FIREBASE" = true ]; then
            echo "  [DRY RUN] Would run: firebase deploy --only hosting"
        fi
        return
    fi

    echo "  Building web release..."
    flutter build web --release
    echo "  ✓ Web build complete: build/web/"

    if [ "$DEPLOY_FIREBASE" = true ]; then
        require_cmd firebase \
            "Install Firebase CLI: npm install -g firebase-tools && firebase login"
        echo "  Deploying to Firebase Hosting..."
        firebase deploy --only hosting
        echo "  ✓ Deployed to Firebase Hosting"
        echo "  URL: https://app-for-mom-d54a2.web.app"
    else
        echo ""
        echo "  Web build is ready. To deploy, either:"
        echo "    • Run: firebase deploy --only hosting"
        echo "    • Or re-run with: $0 web --deploy"
        echo "  Local preview: cd build/web && python3 -m http.server 8080"
    fi
}

# ---- Build & Deploy: Android ----
deploy_android() {
    echo ""
    echo "--- Android Deployment ---"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would run: flutter build apk --release"
        return
    fi

    if [ ! -d "$PROJECT_DIR/android" ]; then
        echo "  Android platform not initialized. Creating..."
        flutter create --platforms=android .
        echo "  ✓ Android platform created"
    fi

    echo "  Building Android APK (release)..."
    flutter build apk --release

    local apk_path="build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$apk_path" ]; then
        local apk_size=$(du -h "$apk_path" | cut -f1)
        echo "  ✓ APK built: $apk_path ($apk_size)"
        echo ""
        echo "  Share this file with Android family members."
        echo "  They need to enable 'Install unknown apps' before installing."
    else
        echo "  ERROR: APK not found at expected path. Build may have failed."
        exit 1
    fi
}

# ---- Build & Deploy: iOS ----
deploy_ios() {
    echo ""
    echo "--- iOS Deployment ---"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would run: flutter build ios --release"
        echo "  [DRY RUN] Then: open ios/Runner.xcworkspace in Xcode → Product → Archive"
        return
    fi

    require_cmd xcrun \
        "Install Xcode from the Mac App Store."

    echo "  Building iOS release..."
    flutter build ios --release
    echo "  ✓ iOS build complete"

    echo ""
    echo "  Next steps for TestFlight distribution:"
    echo "    1. open ios/Runner.xcworkspace"
    echo "    2. Select Product → Archive in Xcode"
    echo "    3. Distribute App → App Store Connect → Upload"
    echo "    4. In App Store Connect → TestFlight → Add testers"
    echo ""
    echo "  See docs/DEPLOYMENT.md for detailed instructions."
}

# ---- Main ----
echo ""
echo "[2/4] Updating passcode..."
update_passcode

run_tests

echo ""
echo "[3/4] Getting dependencies..."
if [ "$DRY_RUN" = false ]; then
    flutter pub get
    echo "  ✓ Dependencies resolved"
fi

echo ""
echo "[4/4] Deploying..."

case "$PLATFORM" in
    web)
        deploy_web
        ;;
    android)
        deploy_android
        ;;
    ios)
        deploy_ios
        ;;
    all)
        deploy_web
        deploy_android
        deploy_ios
        ;;
esac

echo ""
echo "=============================================="
if [ "$DRY_RUN" = true ]; then
    echo " Dry run complete. Remove --dry-run to execute."
else
    echo " Deploy complete."
fi
echo "=============================================="
