# What you need to set (your side)

Only these. Everything else has defaults.

---

## 1. Frontend – backend URL (required)

**File:** `e-commerce-client/lib/app_config.dart`  
**Setting:** `apiBaseUrl`

| Where you run the app | Set to |
|------------------------|--------|
| Chrome / macOS (backend on same PC) | `http://127.0.0.1:8000` |
| Android **emulator** (backend on same PC) | `http://10.0.2.2:8000` |
| Android **real device** or another machine | Your PC’s IP, e.g. `http://192.168.1.5:8000` |
| Production | Your deployed API URL, e.g. `https://api.yoursite.com` |

You **must** set this so the app can talk to the backend. Change it when you switch (e.g. from Chrome to Android emulator).

---

## 2. Backend – database (optional)

**Folder:** `e-commerce-backend`  
**File:** `.env` (create in project root if missing)

- **No .env:** Django may expect PostgreSQL. If you don’t have it, add:
  - `USE_SQLITE=1`  
  So the backend uses SQLite and runs without PostgreSQL.

- **PostgreSQL:** If you use Postgres, set:
  - `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_PORT`  
  (only if you’re not using `USE_SQLITE=1`)

---

## 3. Backend – email / SMTP (optional)

**Folder:** `e-commerce-backend`  
**File:** `.env`

- **No email config:** OTP and order confirmation are **not** sent. The text is only printed in the terminal where you run the backend. Fine for local dev.

- **Real email (OTP + order confirmation):** Add to `.env`:

| Setting | Example | Purpose |
|--------|---------|--------|
| `EMAIL_BACKEND` | `django.core.mail.backends.smtp.EmailBackend` | Use SMTP |
| `EMAIL_HOST` | `smtp.gmail.com` | SMTP server |
| `EMAIL_PORT` | `587` | SMTP port |
| `EMAIL_USE_TLS` | `true` | Use TLS |
| `EMAIL_HOST_USER` | `your@gmail.com` | SMTP login |
| `EMAIL_HOST_PASSWORD` | upjn ezob xvau hveg | SMTP password |
| `DEFAULT_FROM_EMAIL` | `your@gmail.com` | Sender address |

For Gmail you must use an **App Password**, not your normal password. See `e-commerce-backend/EMAIL_CONFIG.md` for details.

---

## Summary

| What | Where | Required? |
|------|--------|-----------|
| Backend URL | `lib/app_config.dart` → `apiBaseUrl` | **Yes** – set for your run (Chrome / emulator / device) |
| Use SQLite | `e-commerce-backend/.env` → `USE_SQLITE=1` | Only if you don’t use PostgreSQL |
| SMTP (real email) | `e-commerce-backend/.env` → `EMAIL_*` | No – only if you want real OTP/order emails |

Nothing else is required from your side for the app to run.
