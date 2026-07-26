#!/bin/bash
# =============================================================================
# Startup Script — App for Mom
# Brings up the testable environment: installs dependencies, launches iOS
# simulator, and runs the Flutter app.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=============================================="
echo " App for Mom — Environment Startup"
echo "=============================================="

# ---- Check prerequisites ----
echo ""
echo "[1/4] Checking prerequisites..."

if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter SDK not found. Please install Flutter first."
    exit 1
fi
echo "  ✓ Flutter SDK found: $(flutter --version 2>/dev/null | head -1 || echo 'unknown')"

# ---- Install dependencies ----
echo ""
echo "[2/4] Installing Flutter dependencies..."
cd "$PROJECT_DIR"
flutter pub get
echo "  ✓ Dependencies installed"

# ---- Launch iOS Simulator ----
echo ""
echo "[3/4] Launching iOS Simulator..."
SIMULATOR_UDID=$(xcrun simctl list devices | grep -m1 "iPhone.*Booted" | grep -oE '\([A-F0-9-]+\)' | tr -d '()' || true)

if [ -z "$SIMULATOR_UDID" ]; then
    # No booted simulator — boot the first available iPhone
    SIMULATOR_UDID=$(xcrun simctl list devices | grep -m1 "iPhone" | grep -oE '\([A-F0-9-]+\)' | tr -d '()')
    if [ -z "$SIMULATOR_UDID" ]; then
        echo "ERROR: No iOS simulator found. Please install one via Xcode."
        exit 1
    fi
    echo "  Booting simulator: $SIMULATOR_UDID"
    xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || true
    open -a Simulator
    echo "  Waiting for simulator to boot..."
    xcrun simctl bootstatus "$SIMULATOR_UDID" -b 2>/dev/null || sleep 10
else
    open -a Simulator
    echo "  Simulator already booted: $SIMULATOR_UDID"
fi
echo "  ✓ iOS Simulator ready"

# ---- Run Flutter app ----
echo ""
echo "[4/4] Running Flutter app on iOS Simulator..."
cd "$PROJECT_DIR"
echo "  Starting flutter run..."
flutter run -d "$SIMULATOR_UDID"

echo ""
echo "=============================================="
echo " Startup complete."
echo "=============================================="
