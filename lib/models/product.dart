class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.shortDescription,
    required this.stockQuantity,
    required this.inStock,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String price;
  final String shortDescription;
  final int stockQuantity;
  final bool inStock;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      price: (json['price'] ?? '0.00').toString(),
      shortDescription: (json['short_description'] ?? '') as String,
      stockQuantity: (json['stock_quantity'] ?? 0) as int,
      inStock: (json['in_stock'] ?? false) as bool,
      imageUrl: json['image_url'] as String?,
    );
  }
}
