// ============================================================
// core/theme/app_theme.dart — Dark Glassmorphism Design System
// ============================================================
//
// INTEGRATION — Member 5 (UX/Design):
//   All design tokens are defined here. Expand this file to add
//   new color roles, text styles, and component themes.
//   The primary gradient and glass card styles are reused across
//   screens — do not override inline.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTheme {
  AppTheme._();
  // ── Color Palette ─────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);      // Indigo-violet
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color accent = Color(0xFF00D4AA);       // Mint-teal
  static const Color accentLight = Color(0xFF4FFFD6);
  static const Color error = Color(0xFFFF4D6A);
  static const Color warning = Color(0xFFFFB347);
  static const Color success = Color(0xFF4CAF82);
  static const Color surface = Color(0xFF1A1A2E);      // Deep navy
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color background = Color(0xFF0F0F23);   // Near-black navy
  static const Color onSurface = Color(0xFFE8E8F0);
  static const Color onSurfaceMuted = Color(0xFF8A8AA0);
  static const Color divider = Color(0xFF2A2A45);
  // ── Glass Surface ─────────────────────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);   // 10% white
  static const Color glassBorder = Color(0x33FFFFFF);  // 20% white
  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF9D50BB)],
  );
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surfaceVariant],
  );
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF00A8CC)],
  );
  // ── Typography ────────────────────────────────────────────
  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -1.0,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
        letterSpacing: 0.15,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceMuted,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: 0.5,
      ),
    );
  }
  // ── Input Decoration ──────────────────────────────────────
  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: glassWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: glassBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: glassBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      labelStyle: const TextStyle(color: onSurfaceMuted),
      hintStyle: const TextStyle(color: onSurfaceMuted),
      prefixIconColor: onSurfaceMuted,
      suffixIconColor: onSurfaceMuted,
    );
  }
  // ── ElevatedButton ────────────────────────────────────────
  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }
  // ── ThemeData ─────────────────────────────────────────────
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: primaryDark,
        secondary: accent,
        secondaryContainer: Color(0xFF004D40),
        surface: surface,
        background: background,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onBackground: onSurface,
        onError: Colors.white,
        surfaceVariant: surfaceVariant,
        outline: divider,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _buildTextTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: const TextStyle(color: onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
// ── Glass Card Decoration (reusable) ─────────────────────────
BoxDecoration glassDecoration({
  double borderRadius = 20,
  Color? color,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: color ?? AppTheme.glassWhite,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: borderColor ?? AppTheme.glassBorder,
      width: 1,
    ),
  );
}
