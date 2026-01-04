import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Primary button with Apple-like styling
class LoyaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final IconData? icon;
  final double? width;
  final double height;

  const LoyaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDestructive
        ? AppColors.error
        : isOutlined
            ? Colors.transparent
            : AppColors.primary;

    final foregroundColor = isOutlined
        ? (isDestructive ? AppColors.error : AppColors.primary)
        : Colors.white;

    final borderSide = isOutlined
        ? BorderSide(
            color: isDestructive ? AppColors.error : AppColors.border,
            width: 1,
          )
        : BorderSide.none;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor,
                side: borderSide,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _buildChild(foregroundColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                disabledBackgroundColor: AppColors.disabled,
                disabledForegroundColor: AppColors.textDisabled,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _buildChild(foregroundColor),
            ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.button),
        ],
      );
    }

    return Text(label, style: AppTypography.button);
  }
}

/// Secondary/Text button
class LoyaTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isDestructive;

  const LoyaTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.button.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Icon button with subtle background
class LoyaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  const LoyaIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: size * 0.5,
          color: color ?? AppColors.textSecondary,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: size,
          minHeight: size,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
