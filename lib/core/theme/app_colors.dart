import 'package:flutter/material.dart';

/// Apple-inspired color palette
/// Clean, confident, neutral with purposeful accents
class AppColors {
  AppColors._();

  // Primary Brand
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF47A3FF);
  static const Color primaryDark = Color(0xFF0056B3);

  // Secondary
  static const Color secondary = Color(0xFF5856D6);

  // Backgrounds
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF9F9F9);
  static const Color inputBackground = Color(0xFFF2F2F7);

  // Text
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textDisabled = Color(0xFFC7C7CC);

  // Borders & Dividers
  static const Color border = Color(0xFFD2D2D7);
  static const Color borderLight = Color(0xFFE5E5EA);
  static const Color divider = Color(0xFFE5E5EA);

  // States
  static const Color disabled = Color(0xFFE5E5EA);
  static const Color hover = Color(0xFFF5F5F7);
  static const Color pressed = Color(0xFFE5E5EA);

  // Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color info = Color(0xFF007AFF);
  static const Color infoLight = Color(0xFFD1E7FF);

  // Program Colors (Apple-inspired palette)
  static const Color programBlue = Color(0xFF007AFF);
  static const Color programGreen = Color(0xFF34C759);
  static const Color programOrange = Color(0xFFFF9500);
  static const Color programRed = Color(0xFFFF3B30);
  static const Color programPurple = Color(0xFFAF52DE);
  static const Color programIndigo = Color(0xFF5856D6);
  static const Color programTeal = Color(0xFF00C7BE);
  static const Color programPink = Color(0xFFFF2D55);

  // Chart Colors
  static const List<Color> chartColors = [
    programBlue,
    programGreen,
    programOrange,
    programPurple,
    programTeal,
    programPink,
  ];

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  // Shadows - using withValues for Flutter 3.27+ compatibility
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Helper to create Color from hex
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Helper to create a color with alpha value (Flutter 3.27+ compatible)
  /// Use instead of deprecated withOpacity
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }
}
