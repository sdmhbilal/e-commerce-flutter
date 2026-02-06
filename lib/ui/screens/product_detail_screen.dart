import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../core/route_observer.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../widgets/empty_state.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with RouteAware {
  bool _routeObserverSubscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && !_routeObserverSubscribed) {
      routeObserver.subscribe(this, route);
      _routeObserverSubscribed = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProduct(widget.productId);
    });
  }

  @override
  void dispose() {
    if (_routeObserverSubscribed) routeObserver.unsubscribe(this);
    context.read<ProductsProvider>().clearSingleProduct();
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<ProductsProvider>().fetchProduct(widget.productId);
    context.read<CartProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();
    final cart = context.read<CartProvider>();
    final theme = Theme.of(context);

    if (products.singleLoading && products.singleProduct == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (products.singleError != null && products.singleProduct == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load product',
          subtitle: products.singleError,
          action: FilledButton.icon(
            onPressed: () => products.fetchProduct(widget.productId),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Retry'),
          ),
        ),
      );
    }

    final product = products.singleProduct;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductDetailImage(imageUrl: product.imageUrl, theme: theme),
            const SizedBox(height: 20),
            Text(
              product.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    '${AppStrings.currency} ${product.price}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    product.inStock
                        ? 'In stock · ${product.stockQuantity}'
                        : 'Out of stock',
                  ),
                  backgroundColor: product.inStock
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: product.inStock ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              product.shortDescription.isEmpty ? 'No description' : product.shortDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: product.inStock
                  ? () async {
                      try {
                        await cart.addItem(productId: product.id, quantity: 1);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to cart'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 22),
              label: Text(product.inStock ? 'Add to cart' : 'Out of stock'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailImage extends StatelessWidget {
  const _ProductDetailImage({this.imageUrl, required this.theme});

  final String? imageUrl;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight < 600
        ? (screenHeight * 0.4).clamp(200.0, 320.0)
        : 320.0;
    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: theme.colorScheme.outline,
                ),
              )
            : Center(
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    size: 80,
                    color: theme.colorScheme.outline,
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                (progress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
