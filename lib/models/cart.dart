import 'cart_item.dart';

export 'cart_item.dart';

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
