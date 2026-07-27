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

if ! command -v xcrun &> /dev/null; then
    echo "ERROR: xcrun not found. Please install Xcode from the Mac App Store."
    echo "  After installation, open Xcode once to accept the license, then run:"
    echo "    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

if ! xcrun simctl list devices &>/dev/null; then
    echo "ERROR: simctl not available. Ensure Xcode is installed and selected:"
    echo "    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo "  Current xcode-select path: $(xcode-select -p 2>/dev/null || echo 'not set')"
    exit 1
fi
echo "  ✓ Xcode tools found"

if ! command -v pod &> /dev/null; then
    echo "ERROR: CocoaPods not found. Install it with: brew install cocoapods"
    exit 1
fi
echo "  ✓ CocoaPods found"

# ---- Install dependencies ----
echo ""
echo "[2/4] Installing Flutter dependencies..."
cd "$PROJECT_DIR"
flutter pub get
echo "  ✓ Dependencies installed"

# ---- Launch iOS Simulator ----
echo ""
echo "[3/4] Launching iOS Simulator..."

# Check if any simulator runtimes exist
RUNTIMES=$(xcrun simctl list runtimes -j 2>/dev/null | grep -c '"identifier"' || true)
if [ "$RUNTIMES" -eq 0 ] 2>/dev/null; then
    echo "ERROR: No iOS simulator runtimes found."
    echo "  Open Xcode → Settings → Platforms → Download iOS Simulator."
    exit 1
fi

SIMULATOR_UDID=$(xcrun simctl list devices | grep -m1 "iPhone.*Booted" | grep -oE '\([A-F0-9-]+\)' | tr -d '()' || true)

if [ -z "$SIMULATOR_UDID" ]; then
    # No booted simulator — find or create one
    SIMULATOR_UDID=$(xcrun simctl list devices | grep -m1 "iPhone" | grep -oE '\([A-F0-9-]+\)' | tr -d '()' || true)

    if [ -z "$SIMULATOR_UDID" ]; then
        # No simulators exist at all — create one
        echo "  No simulator found. Creating a new iPhone simulator..."
        # Get the latest iPhone device type
        DEVICE_TYPE=$(xcrun simctl list devicetypes -j 2>/dev/null | python3 -c "
import json, sys
types = json.load(sys.stdin)['devicetypes']
iphones = [t for t in types if 'iPhone' in t['name'] and 'SE' not in t['name']]
print(iphones[-1]['identifier'] if iphones else '')
" 2>/dev/null)

        if [ -z "$DEVICE_TYPE" ]; then
            echo "ERROR: Could not determine a valid iPhone device type."
            exit 1
        fi

        SIMULATOR_UDID=$(xcrun simctl create "iPhone" "$DEVICE_TYPE" 2>/dev/null || true)
        if [ -z "$SIMULATOR_UDID" ]; then
            echo "ERROR: Failed to create simulator. Check that a runtime is installed:"
            echo "  Open Xcode → Settings → Platforms → Download iOS Simulator."
            exit 1
        fi
        echo "  Created simulator: $SIMULATOR_UDID"
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
