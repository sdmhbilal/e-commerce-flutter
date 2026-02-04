#!/bin/bash
# Run the Flutter app on Android. Start the emulator and backend first (see SETUP_ANDROID_ONCE.md).

set -e
cd "$(dirname "$0")"

echo "Checking for Android device/emulator..."
if ! flutter devices | grep -q android; then
  echo ""
  echo "No Android device or emulator found."
  echo "1. Open Android Studio → Device Manager"
  echo "2. Start an emulator (click Play)"
  echo "3. Run this script again: ./run_android.sh"
  echo ""
  echo "First time? See SETUP_ANDROID_ONCE.md"
  exit 1
fi

echo "Running app on Android..."
flutter pub get
# Use device ID (e.g. emulator-5554) - "flutter run -d android" often fails to match
ANDROID_ID=$(flutter devices 2>&1 | grep -E 'emulator|android' | head -1 | awk -F ' • ' '{print $2}' | tr -d ' ')
if [ -n "$ANDROID_ID" ]; then
  echo "Using device: $ANDROID_ID"
  flutter run -d "$ANDROID_ID"
else
  flutter run -d android
fi
