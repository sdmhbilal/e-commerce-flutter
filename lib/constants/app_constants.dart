abstract class StorageKeys {
  static const String authToken = 'auth_token';
  static const String cartToken = 'cart_token';
}

abstract class ApiPaths {
  static const String authMe = '/api/auth/me/';
  static const String authLogin = '/api/auth/login/';
  static const String authLogout = '/api/auth/logout/';
  static const String authRegister = '/api/auth/register/';
  static const String authVerifyEmail = '/api/auth/verify-email/';
  static const String authProfile = '/api/auth/profile/';
  static const String authVerifyEmailChange = '/api/auth/verify-email-change/';
  static const String authProfileAvatar = '/api/auth/profile/avatar/';
  static const String cart = '/api/cart/';
  static String cartItems(int itemId) => '/api/cart/items/$itemId/';
  static const String cartItemsCreate = '/api/cart/items/';
  static String cartItemDelete(int itemId) => '/api/cart/items/$itemId/delete/';
  static const String couponsValidate = '/api/coupons/validate/';
  static const String orders = '/api/orders/';
  static const String myOrders = '/api/my-orders/';
  static const String products = '/api/products/';
  static String product(int id) => '/api/products/$id/';
}

abstract class AppStrings {
  static const String appTitle = 'E‑Commerce';
  static const String currency = 'PKR';
  static const String storefront = 'Storefront';
  static const String yourCart = 'Your cart';
  static const String checkout = 'Checkout';
  static const String profile = 'Profile';
  static const String myOrders = 'My orders';
  static const String orderPlaced = 'Order placed';
}

abstract class Dimensions {
  static const double radiusSmall = 12;
  static const double radiusMedium = 14;
  static const double radiusLarge = 20;
}
