import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../app_config.dart';
import '../core/api_client.dart';
import '../core/http_utils.dart';
import '../models/product.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider() : _api = ApiClient(AppConfig.apiBaseUrl);

  final ApiClient _api;

  bool loading = false;
  String? error;
  List<Product> products = <Product>[];

  Product? singleProduct;
  bool singleLoading = false;
  String? singleError;

  Future<Product?> fetchProduct(int id) async {
    singleLoading = true;
    singleError = null;
    singleProduct = null;
    notifyListeners();
    try {
      final res = await _api.get('/api/products/$id/');
      if (res.statusCode == 404) {
        singleError = 'Product not found';
        singleLoading = false;
        notifyListeners();
        return null;
      }
      if (res.statusCode >= 400) {
        singleError = errorFromResponse(res).message;
        singleLoading = false;
        notifyListeners();
        return null;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      singleProduct = Product.fromJson(data);
      singleLoading = false;
      notifyListeners();
      return singleProduct;
    } catch (e) {
      singleError = e.toString();
      singleLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearSingleProduct() {
    singleProduct = null;
    singleError = null;
    notifyListeners();
  }

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _api.get('/api/products/');
      if (res.statusCode >= 400) {
        loading = false;
        error = errorFromResponse(res).message;
        notifyListeners();
        return;
      }
      final list = jsonDecode(res.body) as List<dynamic>;
      products = list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      loading = false;
      error = 'Cannot reach server. Start the backend (python manage.py runserver) at ${AppConfig.apiBaseUrl}';
      notifyListeners();
      return;
    }
    loading = false;
    notifyListeners();
  }
}

