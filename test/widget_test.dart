import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_client/main.dart';

void main() {
  testWidgets('App loads and shows storefront', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
