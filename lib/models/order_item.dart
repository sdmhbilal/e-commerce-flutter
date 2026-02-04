class OrderItem {
  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int id;
  final dynamic product;
  final int quantity;
  final String unitPrice;
  final String lineTotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      product: json['product'],
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] ?? '0.00').toString(),
      lineTotal: (json['line_total'] ?? '0.00').toString(),
    );
  }
}
