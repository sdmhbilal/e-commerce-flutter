import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../core/snackbar_utils.dart';
import '../../models/cart.dart';
import '../../providers/cart_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empty_state.dart';
import 'checkout_screen.dart';

Future<void> _updateQuantity(BuildContext context, CartProvider cart, int itemId, int quantity) async {
  try {
    await cart.updateItem(itemId: itemId, quantity: quantity);
  } catch (e) {
    if (context.mounted) showErrorSnackBar(context, e);
  }
}

Future<void> _removeItem(BuildContext context, CartProvider cart, int itemId) async {
  try {
    await cart.removeItem(itemId: itemId);
  } catch (e) {
    if (context.mounted) showErrorSnackBar(context, e);
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.cart?.items ?? [];

    return AppScaffold(
      title: AppStrings.yourCart,
      body: cart.loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Add items from the store to get started.',
                  action: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.storefront_outlined, size: 20),
                    label: const Text('Browse products'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return Padding(
                      key: ValueKey(it.id),
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CartItemTile(item: it),
                    );
                  },
                ),
      bottom: items.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subtotal',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            Text(
                              '${AppStrings.currency} ${cart.cart?.subtotal ?? '0.00'}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        ),
                        child: const Text(AppStrings.checkout),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;
    final cart = context.read<CartProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _CartItemImage(imageUrl: product.imageUrl, theme: theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.currency} ${item.unitPrice} each',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: item.quantity > 1
                        ? () => _updateQuantity(context, cart, item.id, item.quantity - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${item.quantity}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _updateQuantity(context, cart, item.id, item.quantity + 1),
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeItem(context, cart, item.id),
              icon: const Icon(Icons.delete_outline, size: 22),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(36, 36),
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemImage extends StatelessWidget {
  const _CartItemImage({this.imageUrl, required this.theme});

  final String? imageUrl;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(Icons.image_outlined, color: theme.colorScheme.outline, size: 28)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  color: theme.colorScheme.outline,
                  size: 28,
                ),
              ),
      ),
    );
  }
}
