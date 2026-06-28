import 'package:flutter/material.dart';

class MovanaColors {
  static const background = Color(0xFF0D0D0D);
  static const card = Color(0xFF181818);
  static const accent = Color(0xFFF5C518);
  static const watchlist = Color(0xFFFF3B5C);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB5B5B5);
  static const divider = Color(0x14FFFFFF);
}

class MovanaTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: MovanaColors.background,
      colorScheme: const ColorScheme.dark(
        primary: MovanaColors.accent,
        secondary: MovanaColors.watchlist,
        surface: MovanaColors.card,
        onPrimary: Colors.black,
        onSurface: MovanaColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: MovanaColors.textPrimary,
        displayColor: MovanaColors.textPrimary,
      ),
      cardTheme: CardTheme(
        color: MovanaColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MovanaColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: MovanaColors.card,
        selectedColor: MovanaColors.accent,
        labelStyle: const TextStyle(color: MovanaColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}