# E‑Commerce Client

Flutter app for the e‑commerce platform: products, cart, checkout, auth (login/OTP signup), profile, and order history. Pairs with the Django backend (`e-commerce-backend`).

## Project structure

```
lib/
├── config/
│   └── env.dart
├── constants/
│   └── app_constants.dart
├── core/
│   ├── api_client.dart
│   ├── http_utils.dart
│   └── snackbar_utils.dart
├── main.dart
├── models/
│   ├── cart.dart
│   ├── cart_item.dart
│   ├── order.dart
│   ├── order_item.dart
│   └── product.dart
├── providers/
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── orders_provider.dart
│   └── products_provider.dart
├── theme/
│   └── app_theme.dart
└── ui/
    ├── screens/
    └── widgets/
```

## Configuration

### API base URL

Backend URL is read from a **`.env`** file in the project root (same folder as `pubspec.yaml`). Variable: `API_BASE_URL=...` Example: `API_BASE_URL=http://127.0.0.1:8000`. Copy `.env.example` to `.env` if needed. Fallback: `http://127.0.0.1:8000`.

Override at run/build:

```bash
# Android emulator
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Physical device (use your machine’s IP)
flutter run -d android --dart-define=API_BASE_URL=http://192.168.1.5:8000

# Production
flutter build apk --dart-define=API_BASE_URL=https://api.yoursite.com
```

To change the URL, edit `.env` (or create it from `.env.example`).

### Backend

Start the backend first:

```bash
cd e-commerce-backend
.venv/bin/python manage.py runserver 127.0.0.1:8000
```

Email (OTP, order confirmation) is configured on the backend; see the backend README.

## Run the app

```bash
cd e-commerce-client
flutter pub get
flutter run -d chrome
```

For a fixed web URL: `flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080` then open **http://localhost:8080**.

### Android

**One-time setup**

1. Install [Android Studio](https://developer.android.com/studio).
2. Open it and install the Android SDK when prompted.
3. **More Actions** → **Virtual Device Manager** → **Create Device** (e.g. Pixel 6, API 34) → **Finish**.
4. Start the emulator (Play next to the device).

**Every time**

1. Start the backend (see above).
2. From `e-commerce-client` run:
   ```bash
   ./run_android.sh
   ```
   or:
   ```bash
   flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```
   Use `flutter devices` to get `<device-id>`.

For a **physical device** on the same Wi‑Fi, use your machine’s IP in `API_BASE_URL` (e.g. `http://192.168.1.5:8000`).

**Admin dashboard on device**

- Emulator: in device browser open **http://10.0.2.2:8000/dashboard/**.
- Physical device: open **http://&lt;YOUR_MAC_IP&gt;:8000/dashboard/**.
- Log in with dashboard credentials (e.g. admin / Admin@123).

## Features

- **Storefront**: product list, product detail with images, add to cart.
- **Cart**: quantity +/- (optimistic update), remove item, checkout.
- **Checkout**: guest or logged-in; coupon; order placement; full-screen order success.
- **Auth**: login, register (OTP email), verify email, profile (view/edit, avatar, email change with OTP), logout.
- **Orders**: “My orders” from profile; order history with status and total.

Constants and theme: `lib/constants/app_constants.dart`, `lib/theme/app_theme.dart`.
