class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.shortDescription,
    required this.stockQuantity,
    required this.inStock,
    required this.imageUrl,
    required this.imageUrls,
  });

  final int id;
  final String name;
  final String price;
  final String shortDescription;
  final int stockQuantity;
  final bool inStock;
  /// Cover / primary image URL (for list and main detail view).
  final String? imageUrl;
  /// All image URLs (cover + others) so buyer can view all photos.
  final List<String> imageUrls;

  factory Product.fromJson(Map<String, dynamic> json) {
    final cover = json['image_url'] as String?;
    final imagesRaw = json['images'] as List<dynamic>?;
    final List<String> urls = [];
    if (imagesRaw != null) {
      for (final e in imagesRaw) {
        if (e is Map<String, dynamic>) {
          final url = e['image_url'] as String?;
          if (url != null && url.isNotEmpty) urls.add(url);
        }
      }
    }
    if (urls.isEmpty && cover != null && cover.isNotEmpty) urls.add(cover);
    return Product(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      price: (json['price'] ?? '0.00').toString(),
      shortDescription: (json['short_description'] ?? '') as String,
      stockQuantity: (json['stock_quantity'] ?? 0) as int,
      inStock: (json['in_stock'] ?? false) as bool,
      imageUrl: cover,
      imageUrls: urls,
    );
  }
}

