import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF17324D);
  static const blue = Color(0xFF3977B8);
  static const paleBlue = Color(0xFFEAF2FA);
  static const background = Color(0xFFF5F7FA);
  static const muted = Color(0xFF738396);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: navy,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: navy,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(color: navy, fontSize: 14),
          bodySmall: TextStyle(color: muted, fontSize: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: muted),
          prefixIconColor: muted,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
