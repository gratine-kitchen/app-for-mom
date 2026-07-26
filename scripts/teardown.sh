#!/bin/bash
# =============================================================================
# Teardown Script — App for Mom
# Tears down the testable environment: stops Flutter app, shuts down iOS
# simulator, and cleans up.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=============================================="
echo " App for Mom — Environment Teardown"
echo "=============================================="

# ---- Stop Flutter run ----
echo ""
echo "[1/3] Stopping Flutter app..."
# Kill any running flutter processes for this project
pkill -f "flutter.*run" 2>/dev/null || true
pkill -f "dart.*app_for_mom" 2>/dev/null || true
echo "  ✓ Flutter processes stopped"

# ---- Shut down iOS Simulators ----
echo ""
echo "[2/3] Shutting down iOS Simulators..."
xcrun simctl shutdown all 2>/dev/null || true
echo "  ✓ All simulators shut down"

# ---- Clean build artifacts (optional) ----
echo ""
echo "[3/3] Cleaning build artifacts..."
cd "$PROJECT_DIR"
flutter clean 2>/dev/null || true
echo "  ✓ Build artifacts cleaned"

echo ""
echo "=============================================="
echo " Teardown complete."
echo "=============================================="
