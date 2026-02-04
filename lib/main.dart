import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'ui/screens/products_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..load()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..refresh()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        title: 'E‑Commerce',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.light,
        home: const ProductsScreen(),
      ),
    );
  }
}

ThemeData _buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D9488),
    brightness: Brightness.light,
    primary: const Color(0xFF0D9488),
    secondary: const Color(0xFF0891B2),
  );
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.primary.withOpacity(0.08),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant.withOpacity(0.5)),
  );
}

ThemeData _buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2DD4BF),
    brightness: Brightness.dark,
    primary: const Color(0xFF2DD4BF),
    secondary: const Color(0xFF22D3EE),
  );
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 2,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
