# Run the app on Android

## How to check the app on Android

1. **Set the backend URL** in `lib/app_config.dart`:
   - **Android emulator:** use `http://10.0.2.2:8000` (so the emulator can reach your machine).
   - **Real device:** use your computer’s LAN IP (e.g. `http://192.168.1.5:8000`).
2. **Start the backend** on your machine (e.g. `python manage.py runserver 127.0.0.1:8000` in `e-commerce-backend`).
3. **Run the Flutter app:** from `e-commerce-client` run:
   ```bash
   flutter pub get
   flutter run -d android
   ```
4. **What to verify on the device:** login/signup (with first/last name and OTP), profile screen (name, email, **avatar with initials**), edit profile, product list and detail (images), cart, checkout, and order confirmation.

---

## 1. Backend URL on Android

On a **real device** or **emulator**, the app cannot use `http://127.0.0.1:8000` (that is your computer). Use:

- **Android emulator:** `http://10.0.2.2:8000` (emulator’s alias for your machine’s localhost).
- **Real device on same Wi‑Fi:** your computer’s LAN IP, e.g. `http://192.168.1.5:8000`.

Set this in **`lib/app_config.dart`**:

```dart
// For Android emulator (backend on same machine):
static const String apiBaseUrl = 'http://10.0.2.2:8000';

// For real device (replace with your PC’s IP):
// static const String apiBaseUrl = 'http://192.168.1.5:8000';
```

Or use a **build flavour / env** so you can switch URL per build.

## 2. Run on emulator

1. Start an Android emulator (Android Studio → AVD Manager → Play).
2. In project root:
   ```bash
   cd e-commerce-client
   flutter pub get
   flutter run -d android
   ```
3. Flutter will build and install the app on the emulator.

## 3. Run on a real device

1. Enable **Developer options** and **USB debugging** on the phone.
2. Connect the phone via USB.
3. Set `apiBaseUrl` in `lib/app_config.dart` to your computer’s IP (e.g. `http://192.168.1.5:8000`).
4. Ensure the backend is running on that machine and reachable (firewall may need to allow port 8000).
5. Run:
   ```bash
   flutter run -d android
   ```
   If multiple devices are connected, pick the device when prompted or use:
   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

## 4. Product image on Android

Product detail uses a responsive image height so the full image fits on small screens (no cropping). Height is based on screen size so it works on phones and tablets.

## 5. Build release APK

1. Set `apiBaseUrl` in `lib/app_config.dart` to your **deployed backend URL** (e.g. `https://your-api.com`).
2. Run:
   ```bash
   flutter build apk --release
   ```
3. APK path: `build/app/outputs/flutter-apk/app-release.apk`.
