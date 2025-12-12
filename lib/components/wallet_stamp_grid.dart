import 'dart:math' as math;

import 'package:flutter/material.dart';

class WalletStampGrid extends StatelessWidget {
  const WalletStampGrid({
    super.key,
    required this.total,
    required this.filled,
    required this.activeColor,
    required this.borderColor,
    this.inactiveColor,
    this.stampIconUrl,
    this.fallbackIcon = Icons.star_rounded,
  });

  final int total;
  final int filled;
  final Color activeColor;
  final Color borderColor;
  final Color? inactiveColor;
  final String? stampIconUrl;
  final IconData fallbackIcon;

  double _spacingForCount(int count) {
    if (count >= 10) return 6.0;
    if (count >= 7) return 8.0;
    return 10.0;
  }

  double _minSizeForCount(int count) {
    if (count >= 10) return 18.0;
    if (count >= 7) return 22.0;
    return 26.0;
  }

  double _maxSizeForCount(int count) {
    if (count >= 10) return 22.0;
    if (count >= 7) return 28.0;
    return 34.0;
  }

  @override
  Widget build(BuildContext context) {
    final cappedTotal = total.clamp(1, 12);
    final cappedFilled = filled.clamp(0, cappedTotal);
    final rows = (cappedTotal / 6).ceil();
    final firstRowCount = math.min(cappedTotal, 6);
    final secondRowCount = cappedTotal - firstRowCount;
    final spacing = _spacingForCount(cappedTotal);
    final minSize = _minSizeForCount(cappedTotal);
    final maxSize = _maxSizeForCount(cappedTotal);
    final inactive = inactiveColor ?? activeColor.withOpacity(0.35);

    Widget buildStamp(bool isActive, double size) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.12)
              : borderColor.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? borderColor
                : borderColor.withOpacity(0.55),
            width: 1.1,
          ),
        ),
        child: _stampIcon(isActive, inactive, size),
      );
    }

    Widget buildRow(int count, int offset, BoxConstraints constraints) {
      if (count <= 0) {
        return const SizedBox.shrink();
      }
      final rawSize =
          (constraints.maxWidth - spacing * (count - 1)) / count;
      final size = rawSize.clamp(minSize, maxSize);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = (offset + index) < cappedFilled;
          return Padding(
            padding:
                EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
            child: buildStamp(isActive, size),
          );
        }),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: rows == 1
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceEvenly,
          children: [
            buildRow(firstRowCount, 0, constraints),
            if (rows == 2) SizedBox(height: spacing + 2),
            if (rows == 2) buildRow(secondRowCount, firstRowCount, constraints),
          ],
        );
      },
    );
  }

  Widget _stampIcon(bool isActive, Color inactive, double size) {
    final color = isActive ? activeColor : inactive;
    if (stampIconUrl != null && stampIconUrl!.isNotEmpty) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: Image.network(
          stampIconUrl!,
          width: size * 0.6,
          height: size * 0.6,
          fit: BoxFit.contain,
        ),
      );
    }
    return Icon(
      fallbackIcon,
      color: color,
      size: size * 0.6,
    );
  }
}
