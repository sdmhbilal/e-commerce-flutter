# E‑Commerce Client — Frontend Examination

Flutter app in `Documents/e-commerce-client`. This doc maps the codebase to the assignment so we can finish the frontend and build the Android APK.

---

## 1. Project structure

```
lib/
├── main.dart                 # App entry, MultiProvider, MaterialApp, home: ProductsScreen
├── app_config.dart           # API base URL (change for Android emulator / deployed backend)
├── core/
│   ├── api_client.dart       # HTTP client: get/post/patch/delete, auth + cart token headers
│   └── http_utils.dart       # ApiError, decodeJson, errorFromResponse
├── models/
│   ├── product.dart          # Product (id, name, price, shortDescription, stockQuantity, inStock, imageUrl)
│   ├── cart.dart             # Cart, CartItem (id, product, quantity, unitPrice)
│   └── order.dart            # Order, OrderItem (status, guest info, coupon, amounts)
├── providers/
│   ├── auth_provider.dart    # login, register, logout, token persistence
│   ├── cart_provider.dart    # refresh, addItem, updateItem, removeItem, applyCoupon, checkout
│   └── products_provider.dart # fetch products from API
└── ui/
    ├── screens/
    │   ├── products_screen.dart   # Product list, add to cart, nav to cart & login
    │   ├── cart_screen.dart       # Cart items, quantity +/- , remove, checkout button
    │   ├── checkout_screen.dart   # Coupon apply, guest/linked account, place order
    │   └── login_screen.dart      # Login / Register form
    └── widgets/
        ├── app_scaffold.dart      # Scaffold with title + actions
        ├── empty_state.dart       # Icon + title + subtitle + optional action
        └── section_card.dart      # Card with title for checkout sections
```

---

## 2. Assignment requirements vs implementation

### User application (Flutter)

| Requirement | Status | Where |
|-------------|--------|--------|
| Guest browse products | ✅ | `ProductsScreen` — no login required |
| Guest add to cart | ✅ | `CartProvider.addItem`, cart token (guest) in API client |
| At checkout: login/register OR guest (name + email) | ✅ | `CheckoutScreen`: auth block or guest fields + “Or login / register” |
| Guest order details stored | ✅ | Backend; frontend sends `guest_full_name`, `guest_email` in `checkout()` |
| Product list with image, name, price, short description, stock | ✅ | `ProductsScreen` + `Product` model |
| Add to cart | ✅ | Product tile tap → `cart.addItem(productId, quantity: 1)` |
| Update quantity in cart | ✅ | `CartScreen`: +/- buttons → `cart.updateItem(itemId, quantity)` |
| Remove from cart | ✅ | Trash icon → `cart.removeItem(itemId)` |
| Cart supports multiple products | ✅ | `Cart.items` list, API supports multiple items |
| Place order from cart (no payment) | ✅ | `CheckoutScreen` → `cart.checkout(...)` → order confirmation dialog |
| Validate product stock / min order | ✅ | Backend validates; frontend shows API error (e.g. “Insufficient stock”, “Cart is empty”) |
| Coupon at checkout: input, show discount & payable, handle errors | ✅ | Coupon field + Apply → `cart.applyCoupon(code)`; shows applied code, discount, total; errors in SnackBar |

### Tech

| Item | Status |
|------|--------|
| Flutter | ✅ |
| Provider for state | ✅ (auth, cart, products) |
| Android APK | ⚠️ To do: `flutter build apk --release` and point app to deployed backend (see below) |

---

## 3. API usage (backend base: `AppConfig.apiBaseUrl`)

| Purpose | Method | Path | Auth | Cart token |
|---------|--------|------|------|------------|
| Register | POST | `/api/auth/register/` | No | No |
| Login | POST | `/api/auth/login/` | No | No |
| Products list | GET | `/api/products/` | No | No |
| Cart get/create | GET | `/api/cart/` | No | Optional (X-Cart-Token) |
| Add cart item | POST | `/api/cart/items/` | No | Yes |
| Update cart item | PATCH | `/api/cart/items/<id>/` | No | Yes |
| Remove cart item | DELETE | `/api/cart/items/<id>/delete/` | No | Yes |
| Validate coupon | POST | `/api/coupons/validate/` | No | Yes |
| Create order | POST | `/api/orders/` | Optional | Yes |

Auth: `Authorization: Token <token>`. Cart: `X-Cart-Token: <uuid>` (stored in SharedPreferences after first cart response).

---

## 4. Navigation flow

- **Home:** `ProductsScreen` (storefront).
- **App bar:** Person icon → `LoginScreen`; bag icon → `CartScreen`.
- **Products:** Tap product (if in stock) → add to cart → snackbar.
- **Cart:** “Checkout” → `CheckoutScreen`.
- **Checkout:** Coupon apply → guest name/email or logged-in account → “Place order” → success dialog → pop to previous screen.
- **Login/Register:** From products (person icon) or checkout (“Or login / register”). After success, `Navigator.pop()`.

No named routes; all `Navigator.push(MaterialPageRoute(...))`.

---

## 5. Config and deployment

- **API URL:** `lib/app_config.dart` → `static const String apiBaseUrl = 'http://127.0.0.1:8000';`
  - Local: `http://127.0.0.1:8000`
  - Android emulator: `http://10.0.2.2:8000`
  - Deployed backend: set to your EC2 URL (e.g. `https://your-domain.com`) before building the APK.
- For release APK, either:
  - Build with a backend URL baked in (different `apiBaseUrl` per build), or
  - Use a single base URL and switch backend via env/build flavour later.

---

## 6. What’s done and what to do next

**Done**

- Product listing, add/update/remove cart, checkout with guest or login, coupon apply and error handling, order placement and confirmation.
- Auth (login/register) and token persistence.
- Cart token handling so guest cart works across requests.
- Basic error handling (SnackBar for API errors).
- UI: Material 3, Inter font, empty states, loading states.

**To finish for assignment**

1. **Android APK**
   - Set `AppConfig.apiBaseUrl` to the deployed backend URL.
   - Run: `flutter build apk --release`.
   - APK path: `build/app/outputs/flutter-apk/app-release.apk`.
   - Provide this file (or a download link) for submission.

2. **Optional polish**
   - After login from checkout, return to checkout (e.g. pop login then refresh checkout) so user can place order without re-entering.
   - Ensure backend URL is correct for Android device (no `localhost`; use emulator host or deployed URL).
   - If backend uses HTTPS, ensure Android allows cleartext or use HTTPS only.

---

## 7. How to run and build

```bash
# Dependencies
flutter pub get

# Run on Chrome (backend must be at apiBaseUrl)
flutter run -d chrome

# Run on Android emulator (use http://10.0.2.2:8000 for local backend)
flutter run -d android

# Release APK (for submission; set apiBaseUrl first)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 8. Summary

The frontend already implements the assignment’s user flows: guest/product list, cart, login/register, guest checkout, coupon, and order placement. The main follow-ups are: point `apiBaseUrl` to the deployed backend and build the release Android APK for submission.
