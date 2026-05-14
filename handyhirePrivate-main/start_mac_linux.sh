#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  HandyHire — Mac / Linux Starter
#  Run: bash start_mac_linux.sh
# ═══════════════════════════════════════════════════════════════
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "============================================"
echo "       HandyHire — Starting Up"
echo "============================================"
echo ""

# Kill anything already on 8080
lsof -ti:8080 | xargs kill -9 2>/dev/null || true

echo "[1/3] Starting backend..."
cd "$DIR/backend"
chmod +x mvnw
./mvnw spring-boot:run > "$DIR/backend.log" 2>&1 &
BACKEND_PID=$!
echo "      Backend PID $BACKEND_PID — logs at $DIR/backend.log"
echo ""

echo "[2/3] Waiting for backend to be ready (up to 90 seconds)..."
WAITED=0
until curl -s -o /dev/null http://localhost:8080/api/auth/login 2>/dev/null; do
    sleep 3; WAITED=$((WAITED+3))
    printf "      %ds...\r" $WAITED
    if [ $WAITED -ge 90 ]; then
        echo "ERROR: Backend didn't start. Check backend.log"; exit 1
    fi
done
echo ""
echo "      Backend is ready!"
echo ""

echo "[3/3] Starting Flutter..."
echo "      (emulator or device must already be running)"
cd "$DIR/frontend"
flutter run

trap "kill $BACKEND_PID 2>/dev/null" EXIT
