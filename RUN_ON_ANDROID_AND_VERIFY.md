# Run the app on Android and verify for your lead

Follow these steps so the app runs on Android and you can confirm it works.

---

## Step 1: Get an Android target

You need **either** an **Android emulator** **or** a **real Android phone**.

### Option A – Android emulator (recommended)

1. Install **Android Studio** if you don’t have it: https://developer.android.com/studio  
2. Open Android Studio → **More Actions** (or **Tools**) → **Device Manager** (or **AVD Manager**).  
3. Click **Create Device** → pick a phone (e.g. Pixel 6) → **Next** → pick a system image (e.g. API 34) → **Next** → **Finish**.  
4. In Device Manager, click the **Play** button next to your virtual device.  
5. Wait until the emulator is fully booted (you see the home screen).

### Option B – Real Android phone

1. On the phone: **Settings** → **About phone** → tap **Build number** 7 times to enable Developer options.  
2. **Settings** → **Developer options** → turn on **USB debugging**.  
3. Connect the phone to your Mac with a USB cable.  
4. On the phone, if prompted “Allow USB debugging?” tap **Allow**.  
5. On your Mac, run in a terminal: `flutter devices`  
   You should see your device listed (e.g. “sdk gphone64 arm64”).

---

## Step 2: Point the app to your backend

On Android, the app **cannot** use `127.0.0.1` (that’s the device/emulator itself). It must use your **computer’s** backend.

- **Using the emulator:** the emulator calls your Mac at `10.0.2.2`.  
- **Using a real device:** use your Mac’s IP on the same Wi‑Fi (e.g. `192.168.1.5`).

**Edit:** `e-commerce-client/lib/app_config.dart`

**For emulator:** set:

```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000';
```

**For real device:** set (replace with your Mac’s IP):

```dart
static const String apiBaseUrl = 'http://192.168.1.5:8000';  // use your Mac’s IP
```

To find your Mac’s IP: **System Settings** → **Wi‑Fi** → your network → **Details** (or run `ipconfig getifaddr en0` in Terminal).

---

## Step 3: Start the backend on your Mac

In a terminal:

```bash
cd /Users/tayyabali/Documents/e-commerce-backend
.venv/bin/python manage.py runserver 127.0.0.1:8000
```

Leave this running. The app on Android will call this server.

---

## Step 4: Run the app on Android

In **another** terminal:

```bash
cd /Users/tayyabali/Documents/e-commerce-client
flutter pub get
flutter run -d android
```

- If you have **one** Android device/emulator, Flutter will use it.  
- If you have **several**, Flutter will ask you to choose (e.g. `1` for the emulator).  

Wait for the build to finish. The app will install and open on the emulator or phone.

---

## Step 5: Verify it works (for your lead)

On the Android device/emulator, check:

1. **Products** – List loads (from backend).  
2. **Product detail** – Tap a product; detail and images load.  
3. **Cart** – Add to cart; cart screen shows items.  
4. **Login / Sign up** – Register (first name, last name, email, etc.); OTP step appears (if email is configured).  
5. **Profile** – After login, profile shows name, email, avatar/initials.  
6. **Edit profile** – Change name/email; save.  
7. **Checkout** – Cart → Checkout; place order (guest or logged in).

If all of the above work, you can report to your lead: **“App runs on Android and core flows work (products, cart, auth, profile, checkout).”**

---

## Troubleshooting

**“No devices found” when running `flutter run -d android`**  
- Emulator: start it from Android Studio Device Manager first, then run `flutter run -d android` again.  
- Real device: enable USB debugging, reconnect the cable, run `flutter devices`.

**App opens but products don’t load / “Connection refused”**  
- Backend must be running on your Mac (Step 3).  
- In `app_config.dart` you must use `http://10.0.2.2:8000` (emulator) or `http://YOUR_MAC_IP:8000` (real device), not `127.0.0.1`.

**Real device can’t reach backend**  
- Phone and Mac must be on the **same Wi‑Fi**.  
- Use your Mac’s **LAN IP** in `apiBaseUrl` (e.g. `192.168.1.5`).  
- If it still fails, temporarily allow port 8000 in your Mac firewall or try from the emulator first.

---

## Quick checklist for your lead

- [ ] Android emulator or device is running/connected.  
- [ ] `app_config.dart` uses `http://10.0.2.2:8000` (emulator) or `http://<Mac IP>:8000` (device).  
- [ ] Backend is running on Mac (`python manage.py runserver 127.0.0.1:8000`).  
- [ ] `flutter run -d android` has been run; app is open on Android.  
- [ ] Products, product detail, cart, login/signup, profile, and checkout have been tested and work.
