import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Loya logo component - clean, minimal wordmark
class LoyaLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showTagline;

  const LoyaLogo({
    super.key,
    this.size = 48,
    this.color,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo mark (stylized L)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Center(
            child: Text(
              'L',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: size * 0.55,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Wordmark
        Text(
          'LOYA',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: color ?? AppColors.textPrimary,
          ),
        ),

        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Track visits. Reward loyalty.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Horizontal logo for header/navbar
class LoyaLogoHorizontal extends StatelessWidget {
  final double height;
  final Color? color;

  const LoyaLogoHorizontal({
    super.key,
    this.height = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo mark
        Container(
          width: height,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(height * 0.22),
          ),
          child: Center(
            child: Text(
              'L',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: height * 0.55,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Wordmark
        Text(
          'LOYA',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: height * 0.55,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
