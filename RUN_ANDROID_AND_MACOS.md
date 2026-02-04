# Run the app on Android and macOS

## Current status

- **macOS:** App is building/running in the background. A macOS window should open when the build finishes.
- **Android:** No Android emulator or device is connected. Set one up first (see below), then run.

---

## Run on Android

### Option A – Android emulator (recommended if you have Android Studio)

1. **Create/start an emulator**
   - Open **Android Studio** → **Device Manager** (or **AVD Manager**).
   - Create a virtual device if you don’t have one (e.g. Pixel 6, API 34).
   - Click **Play** to start the emulator. Wait until it’s fully booted.

2. **Set backend URL for the emulator**  
   In `lib/app_config.dart` set:
   ```dart
   static const String apiBaseUrl = 'http://10.0.2.2:8000';
   ```
   (So the emulator can reach your backend on the host machine.)

3. **Start the backend** (if not already running):
   ```bash
   cd e-commerce-backend
   .venv/bin/python manage.py runserver 127.0.0.1:8000
   ```

4. **Run the app on the emulator:**
   ```bash
   cd e-commerce-client
   flutter pub get
   flutter run -d android
   ```
   Flutter will build, install, and launch the app on the emulator.

### Option B – Real Android device

1. Enable **Developer options** and **USB debugging** on the phone.
2. Connect the phone via USB. Run `flutter devices` and confirm the device appears.
3. In `lib/app_config.dart` set your computer’s IP (same Wi‑Fi as the phone):
   ```dart
   static const String apiBaseUrl = 'http://192.168.x.x:8000';  // e.g. 192.168.1.5
   ```
4. Start the backend on your machine. Then:
   ```bash
   cd e-commerce-client
   flutter run -d android
   ```

---

## Run on macOS

1. **Backend URL** – In `lib/app_config.dart` you can keep:
   ```dart
   static const String apiBaseUrl = 'http://127.0.0.1:8000';
   ```
   (macOS app runs on the same machine as the backend.)

2. **Start the backend** (if not already running):
   ```bash
   cd e-commerce-backend
   .venv/bin/python manage.py runserver 127.0.0.1:8000
   ```

3. **Run the app on macOS:**
   ```bash
   cd e-commerce-client
   flutter run -d macos
   ```
   A native macOS window opens with the app.

---

## Quick reference

| Target   | Command                  | Backend URL (in app_config.dart)     |
|----------|--------------------------|--------------------------------------|
| Android emulator | `flutter run -d android` | `http://10.0.2.2:8000`           |
| Android device   | `flutter run -d android` | `http://YOUR_PC_IP:8000`         |
| macOS            | `flutter run -d macos`   | `http://127.0.0.1:8000`          |

**Note:** If you don’t have Android Studio/emulator yet, install Android Studio, then use **Device Manager** to create and start an AVD. After that, `flutter run -d android` will see it.
