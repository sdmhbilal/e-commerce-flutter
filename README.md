# E-Commerce Client (Flutter)

**Project overview:** Flutter app for products, cart, checkout, auth (login/OTP), profile, orders. Uses the Django backend.

**Tech stack:** Dart 3.10+, Flutter 3.x, Provider ^6.1, http ^1.2, Material 3, SharedPreferences, flutter_dotenv. See `pubspec.yaml` for exact versions.

## Setup instructions

```bash
cd e-commerce-client
flutter pub get
cp .env.example .env   # set API_BASE_URL to backend (e.g. http://127.0.0.1:8000)
```

Run: `flutter run -d chrome` (or `-d android`). For emulator use `API_BASE_URL=http://10.0.2.2:8000` in `.env` or `--dart-define=API_BASE_URL=http://10.0.2.2:8000`.

**Release APK:** `flutter build apk --release --dart-define=API_BASE_URL=https://YOUR_BACKEND_URL`  
Output: `build/app/outputs/flutter-apk/app-release.apk`

## API documentation (basic)

Same as backend: auth, products, cart, coupons, orders. See backend README for full API.
