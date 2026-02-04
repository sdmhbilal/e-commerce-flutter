# Set up Android once – then you can run the app for your lead

Your Mac doesn’t have the Android SDK yet. Do this **once**; after that you can run the app on Android anytime.

---

## Step 1: Install Android Studio (one time)

1. **Download Android Studio**  

2. **Install it**  
   Open the downloaded `.dmg`, drag Android Studio into Applications.

3. **Open Android Studio**  
   First time: it will ask to install the **Android SDK**. Click **Next** and finish.  
   (This can take 10–20 minutes.)

---

## Step 2: Create and start an Android emulator (one time)

1. In Android Studio, go to **More Actions** → **Virtual Device Manager**  
   (or **Tools** → **Device Manager**).

2. Click **Create Device** (or the + button).  
   - Choose a phone (e.g. **Pixel 6**) → **Next**.  
   - Choose a system image (e.g. **API 34**). If it says "Download", click it and wait.  
   - **Next** → **Finish**.

3. In the device list, click the **Play** button next to your device.  
   Wait until the emulator window opens and you see the Android home screen.

---

## Step 3: Run the app on Android (every time)

**Terminal 1 – start the backend (leave it running):**

```bash
cd /Users/tayyabali/Documents/e-commerce-backend
.venv/bin/python manage.py runserver 127.0.0.1:8000
```

**Terminal 2 – run the app on the emulator:**

```bash
cd /Users/tayyabali/Documents/e-commerce-client
./run_android.sh
```

Or, if that fails, use the emulator’s device ID (e.g. from `flutter devices`):

```bash
flutter run -d emulator-5554
```

Wait for the build to finish. The app will open on the emulator.

---

## Done

- The app is already set to use `http://10.0.2.2:8000` so it will talk to your backend on the emulator.  
- For your lead: open the app on the emulator and check products, cart, login, profile, checkout.

**If you want to run on Chrome again:**  
In `e-commerce-client/lib/app_config.dart` change the line to:

```dart
static const String apiBaseUrl = 'http://127.0.0.1:8000';
```

Then run: `flutter run -d chrome`

---

## View the custom admin dashboard on Android

The backend has a **custom admin dashboard** (not Django admin). To open it on the emulator or a device:

1. **Backend must be running** on your Mac:  
   `cd e-commerce-backend && .venv/bin/python manage.py runserver 127.0.0.1:8000`

2. **On the Android emulator:**  
   Open the **Chrome** app (or any browser) on the emulator and go to:
   - **http://10.0.2.2:8000/dashboard/**  
   (`10.0.2.2` is the emulator’s way to reach your Mac’s `localhost`.)

3. **On a physical Android device** (same Wi‑Fi as your Mac):  
   Find your Mac’s IP (e.g. **System Settings → Network → Wi‑Fi → Details**). Then on the phone’s browser open:
   - **http://&lt;YOUR_MAC_IP&gt;:8000/dashboard/**  
   Example: `http://192.168.1.5:8000/dashboard/`

4. **Log in** with your dashboard user (e.g. username `admin`, password `admin123` if you used the default).

You can manage products, orders, and other dashboard features from there.
