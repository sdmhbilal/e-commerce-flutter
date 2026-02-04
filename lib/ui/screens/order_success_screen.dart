import 'package:flutter/material.dart';

import '../../models/order.dart';
import 'products_screen.dart';

/// Full-screen order confirmation so the user sees correct amounts (no checkout with 0 in background).
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = order.discountAmount != null &&
        order.discountAmount!.isNotEmpty &&
        order.discountAmount != '0' &&
        order.discountAmount != '0.00';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Order placed',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #${order.id}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _row(theme, 'Subtotal', 'PKR ${order.subtotalAmount}'),
                    if (hasDiscount) ...[
                      const SizedBox(height: 12),
                      _row(theme, 'Discount', '- PKR ${order.discountAmount}'),
                    ],
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _row(
                      theme,
                      'Total',
                      'PKR ${order.totalAmount}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const ProductsScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
              : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
