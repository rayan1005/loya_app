import 'package:flutter/material.dart';

/// Apple-inspired typography system
/// Clean hierarchy, excellent readability
class AppTypography {
  AppTypography._();

  // Font Families - Using system fonts for web compatibility
  static const String primaryFont =
      '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto';
  static const String secondaryFont =
      '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto';
  static const String arabicFont = 'Cairo, Noto Sans Arabic';

  // Base text style
  static TextStyle _base({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.4,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamilyFallback: const ['Cairo', 'Roboto', 'sans-serif'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Display - Large titles
  static TextStyle get displayLarge => _base(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1.5,
      );

  static TextStyle get displayMedium => _base(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -1,
      );

  static TextStyle get displaySmall => _base(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
      );

  // Headlines
  static TextStyle get headline => _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineSmall => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  // Title
  static TextStyle get title => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get titleMedium => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body
  static TextStyle get bodyLarge => _base(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get body => _base(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  // Label
  static TextStyle get label => _base(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => _base(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.2,
      );

  // Caption
  static TextStyle get caption => _base(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
      );

  static TextStyle get captionSmall => _base(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: 0.2,
      );

  // Button
  static TextStyle get button => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get buttonSmall => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // Numbers (for stats, metrics)
  static TextStyle get numberLarge => _base(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1,
      );

  static TextStyle get numberMedium => _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get numberSmall => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  // Code/Mono
  static TextStyle get mono => const TextStyle(
        fontFamily: 'SF Mono',
        fontFamilyFallback: ['Consolas', 'Monaco', 'monospace'],
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );
}
