import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../core/http_utils.dart';
import '../../core/route_observer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../widgets/section_card.dart';
import 'login_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with RouteAware {
  bool _routeObserverSubscribed = false;
  final _coupon = TextEditingController();
  final _guestName = TextEditingController();
  final _guestEmail = TextEditingController();
  bool _submitting = false;
  final _formKey = GlobalKey<FormState>();

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
  void dispose() {
    if (_routeObserverSubscribed) routeObserver.unsubscribe(this);
    _coupon.dispose();
    _guestName.dispose();
    _guestEmail.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<CartProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.checkout)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SectionCard(
              title: 'Order summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: theme.textTheme.bodyLarge),
                      Text(
                        '${AppStrings.currency} ${cart.cart?.subtotal ?? '0.00'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (cart.appliedCouponCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount (${cart.appliedCouponCode})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '- ${AppStrings.currency} ${cart.discountAmount ?? '0.00'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (payable)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${AppStrings.currency} ${cart.totalAfterDiscount ?? cart.cart?.subtotal ?? '0.00'}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${AppStrings.currency} ${cart.cart?.subtotal ?? '0.00'}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SectionCard(
              title: 'Coupon',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'One coupon per order. Applying a new code replaces the current one.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _coupon,
                          decoration: const InputDecoration(
                            labelText: 'Coupon code',
                            hintText: 'Enter code',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _submitting
                            ? null
                            : () async {
                                if (_coupon.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Enter a coupon code first'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  await cart.applyCoupon(_coupon.text.trim());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Coupon applied'),
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
                              },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  if (cart.appliedCouponCode != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text('${cart.appliedCouponCode} applied'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => cart.clearAppliedCoupon(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Discount: ${AppStrings.currency} ${cart.discountAmount ?? '0.00'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payable: ${AppStrings.currency} ${cart.totalAfterDiscount ?? ''}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SectionCard(
              title: auth.isAuthed ? 'Account' : 'Your details',
              child: auth.isAuthed
                  ? Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Order will be placed under your account.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _guestName,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            hintText: 'Enter your name',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Full name is required for guest checkout';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _guestEmail,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'your@email.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required for guest checkout';
                            }
                            final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!r.hasMatch(v.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          icon: const Icon(Icons.login, size: 20),
                          label: const Text('Or login / register'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _submitting = true);
                      try {
                        final couponToSend = cart.appliedCouponCode ?? _coupon.text.trim();
                        final order = await cart.checkout(
                          auth: auth.isAuthed,
                          couponCode: couponToSend.isEmpty ? null : couponToSend,
                          guestFullName: auth.isAuthed ? null : _guestName.text.trim(),
                          guestEmail: auth.isAuthed ? null : _guestEmail.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => OrderSuccessScreen(order: order),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        final msg = e is ApiError ? e.message : e.toString();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Place order'),
            ),
          ],
        ),
      ),
    );
  }
}
