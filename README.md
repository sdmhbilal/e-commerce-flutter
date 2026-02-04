# e-commerce-client

Flutter e‑commerce app (products, cart, checkout, login/guest, profile, OTP signup, order emails).

## Configuration (what you need to set)

- **Backend URL** – In `lib/app_config.dart` set `apiBaseUrl`:
  - Local (Chrome/macOS): `http://127.0.0.1:8000`
  - Android emulator: `http://10.0.2.2:8000`
  - Real device / other machine: your backend machine’s IP, e.g. `http://192.168.1.5:8000`
- **Email (OTP and order confirmation)** – Configured on the **backend**. See `e-commerce-backend/EMAIL_CONFIG.md` for SMTP and env vars. Without it, OTP and order emails are printed to the backend console only.

## Run the frontend

```bash
cd e-commerce-client
flutter pub get
flutter run -d chrome
```

Chrome opens with the app. The terminal shows the URL (e.g. `http://localhost:12345`).

### URL not working in another tab or browser?

By default the dev server can be picky. Run with a **fixed port** and **host 0.0.0.0** so the same URL works when you paste it in another tab or browser:

```bash
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
```

Then open **http://localhost:8080** (or **http://127.0.0.1:8080**) in any tab or browser on the same machine.

- **Same computer, any browser/tab:** use `http://localhost:8080` or `http://127.0.0.1:8080`.
- **Another device on your network:** use `http://YOUR_PC_IP:8080` (e.g. `http://192.168.1.5:8080`). Keep the backend and CORS set up for that if needed.

## Run on Android

See **[ANDROID_RUN.md](ANDROID_RUN.md)** for how to check the app on Android (emulator or device), including setting `apiBaseUrl` and what to verify (profile with initials avatar, signup/OTP, orders).
