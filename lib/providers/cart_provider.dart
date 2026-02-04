import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';
import '../constants/app_constants.dart';
import '../core/api_client.dart';
import '../core/http_utils.dart';
import '../models/cart.dart';
import '../models/order.dart';

class CartProvider extends ChangeNotifier {
  CartProvider() : _api = ApiClient();

  final ApiClient _api;

  Cart? cart;
  bool loading = false;
  String? error;

  String? appliedCouponCode;
  String? discountAmount;
  String? totalAfterDiscount;

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final res = await _api.get(ApiPaths.cart, cart: true);
      if (res.statusCode >= 400) {
        if (!silent) loading = false;
        error = errorFromResponse(res).message;
        notifyListeners();
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final newCart = Cart.fromJson(data);
      if (newCart.items.isNotEmpty && cart != null && cart!.items.isNotEmpty) {
        final idToIndex = <int, int>{};
        for (var i = 0; i < cart!.items.length; i++) {
          idToIndex[cart!.items[i].id] = i;
        }
        final sorted = List<CartItem>.from(newCart.items);
        sorted.sort((a, b) {
          final ai = idToIndex[a.id] ?? 0x7fffffff;
          final bi = idToIndex[b.id] ?? 0x7fffffff;
          return ai.compareTo(bi);
        });
        cart = Cart(
          id: newCart.id,
          cartToken: newCart.cartToken,
          subtotal: newCart.subtotal,
          totalItems: newCart.totalItems,
          items: sorted,
        );
      } else {
        cart = newCart;
      }
      final token = cart?.cartToken;
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.cartToken, token);
      }
    } catch (e) {
      if (!silent) loading = false;
      error = 'Cannot reach server. Start the backend at ${Env.apiBaseUrl}';
      notifyListeners();
      return;
    }
    if (!silent) loading = false;
    notifyListeners();
  }

  Future<void> addItem({required int productId, int quantity = 1}) async {
    final hasToken = cart?.cartToken != null && cart!.cartToken!.isNotEmpty;
    if (!hasToken) await refresh();
    final res = await _api.post(ApiPaths.cartItemsCreate, cart: true, body: {
      'product_id': productId,
      'quantity': quantity,
    });
    if (res.statusCode >= 400) throw errorFromResponse(res);
    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['cart_token']?.toString();
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.cartToken, token);
      }
    } catch (_) {}
    await refresh();
  }

  Future<void> updateItem({required int itemId, required int quantity}) async {
    final prevCart = cart;
    if (prevCart != null) {
      _applyQuantityOptimistic(itemId, quantity);
      notifyListeners();
    }
    try {
      final res = await _api.patch(ApiPaths.cartItems(itemId), cart: true, body: {'quantity': quantity});
      if (res.statusCode >= 400) throw errorFromResponse(res);
      await refresh(silent: true);
    } catch (_) {
      if (prevCart != null) {
        cart = prevCart;
        notifyListeners();
      }
      rethrow;
    }
  }

  void _applyQuantityOptimistic(int itemId, int quantity) {
    final c = cart;
    if (c == null) return;
    final newItems = c.items.map<CartItem>((i) {
      if (i.id == itemId) {
        return CartItem(id: i.id, product: i.product, quantity: quantity, unitPrice: i.unitPrice);
      }
      return i;
    }).toList();
    double sub = 0;
    for (final i in newItems) {
      sub += (double.tryParse(i.unitPrice) ?? 0) * i.quantity;
    }
    final newTotalItems = newItems.fold<int>(0, (s, i) => s + i.quantity);
    cart = Cart(
      id: c.id,
      cartToken: c.cartToken,
      subtotal: sub.toStringAsFixed(2),
      totalItems: newTotalItems,
      items: newItems,
    );
  }

  Future<void> removeItem({required int itemId}) async {
    final res = await _api.delete(ApiPaths.cartItemDelete(itemId), cart: true);
    if (res.statusCode >= 400) throw errorFromResponse(res);
    await refresh(silent: true);
  }

  Future<void> applyCoupon(String code) async {
    final res = await _api.post(ApiPaths.couponsValidate, cart: true, body: {'code': code});
    if (res.statusCode >= 400) throw errorFromResponse(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    appliedCouponCode = (data['code'] ?? '').toString();
    discountAmount = (data['discount_amount'] ?? '0.00').toString();
    totalAfterDiscount = (data['total_amount'] ?? '0.00').toString();
    notifyListeners();
  }

  void clearAppliedCoupon() {
    appliedCouponCode = null;
    discountAmount = null;
    totalAfterDiscount = null;
    notifyListeners();
  }

  Future<Order> checkout({
    String? couponCode,
    String? guestFullName,
    String? guestEmail,
    bool auth = false,
  }) async {
    final res = await _api.post(
      ApiPaths.orders,
      cart: true,
      auth: auth,
      body: {
        if (couponCode != null && couponCode.trim().isNotEmpty) 'coupon_code': couponCode.trim(),
        if (guestFullName != null) 'guest_full_name': guestFullName,
        if (guestEmail != null) 'guest_email': guestEmail,
      },
    );
    if (res.statusCode >= 400) throw errorFromResponse(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final order = Order.fromJson(data);
    appliedCouponCode = null;
    discountAmount = null;
    totalAfterDiscount = null;
    await refresh();
    return order;
  }
}
