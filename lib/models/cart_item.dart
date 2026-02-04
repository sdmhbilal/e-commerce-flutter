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
