import 'product.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  final int id;
  final Product product;
  final int quantity;
  final String unitPrice;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] ?? '0.00').toString(),
    );
  }
}

class Cart {
  Cart({
    required this.id,
    required this.cartToken,
    required this.subtotal,
    required this.totalItems,
    required this.items,
  });

  final int id;
  final String? cartToken;
  final String subtotal;
  final int totalItems;
  final List<CartItem> items;

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsRaw = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return Cart(
      id: json['id'] as int,
      cartToken: json['cart_token'] as String?,
      subtotal: (json['subtotal'] ?? '0.00').toString(),
      totalItems: (json['total_items'] ?? 0) as int,
      items: itemsRaw,
    );
  }
}

