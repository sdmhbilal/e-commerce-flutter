import 'cart.dart';

class Order {
  Order({
    required this.id,
    required this.status,
    required this.guestFullName,
    required this.guestEmail,
    required this.couponCode,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.items,
    this.createdAt,
  });

  final int id;
  final String status;
  final String guestFullName;
  final String guestEmail;
  final String? couponCode;
  final String subtotalAmount;
  final String discountAmount;
  final String totalAmount;
  final List<OrderItem> items;
  final String? createdAt;

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsRaw = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return Order(
      id: json['id'] as int,
      status: (json['status'] ?? '') as String,
      guestFullName: (json['guest_full_name'] ?? '') as String,
      guestEmail: (json['guest_email'] ?? '') as String,
      couponCode: json['coupon_code'] as String?,
      subtotalAmount: (json['subtotal_amount'] ?? '0.00').toString(),
      discountAmount: (json['discount_amount'] ?? '0.00').toString(),
      totalAmount: (json['total_amount'] ?? '0.00').toString(),
      items: itemsRaw,
      createdAt: json['created_at'] as String?,
    );
  }
}

class OrderItem {
  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int id;
  final dynamic product; // product shape same as Product; keep dynamic for brevity in UI
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

