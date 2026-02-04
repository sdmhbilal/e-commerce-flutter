import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../core/api_client.dart';
import '../core/http_utils.dart';
import '../models/order.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider() : _api = ApiClient();

  final ApiClient _api;

  List<Order> orders = [];
  bool loading = false;
  String? error;

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiPaths.myOrders, auth: true);
      if (res.statusCode >= 400) {
        error = errorFromResponse(res).message;
        orders = [];
        notifyListeners();
        return;
      }
      final list = jsonDecode(res.body) as List<dynamic>;
      orders = list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      error = e.toString();
      orders = [];
    }
    loading = false;
    notifyListeners();
  }
}
