import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../widgets/empty_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myOrders)),
      body: orders.loading
          ? const Center(child: CircularProgressIndicator())
          : orders.error != null
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyState(
                      icon: Icons.error_outline,
                      title: 'Could not load orders',
                      subtitle: orders.error,
                      action: FilledButton.icon(
                        onPressed: () => context.read<OrdersProvider>().fetch(),
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Retry'),
                      ),
                    ),
                  ),
                )
              : orders.orders.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      subtitle: 'Orders you place will appear here.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => context.read<OrdersProvider>().fetch(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: orders.orders.length,
                        itemBuilder: (_, i) {
                          final order = orders.orders[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderCard(order: order, theme: theme),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.theme});

  final Order order;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status == 'shipped'
        ? Colors.green
        : order.status == 'cancelled'
            ? theme.colorScheme.error
            : theme.colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  label: Text(
                    order.status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: statusColor.withOpacity(0.12),
                  side: BorderSide.none,
                ),
              ],
            ),
            if (order.createdAt != null && order.createdAt!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(order.createdAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${order.items.length} item(s) · ${AppStrings.currency} ${order.totalAmount}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
