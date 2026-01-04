import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Live preview of program card (simulates Apple Wallet appearance)
class ProgramPreview extends StatelessWidget {
  final String name;
  final String description;
  final int stampsRequired;
  final String reward;
  final Color color;
  final int currentStamps;

  const ProgramPreview({
    super.key,
    required this.name,
    required this.description,
    required this.stampsRequired,
    required this.reward,
    required this.color,
    this.currentStamps = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: AspectRatio(
          aspectRatio: 1.586, // Credit card ratio
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: _buildBackgroundPattern(),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo placeholder
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.gift,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),

                          // Program name
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                name,
                                style: AppTypography.title.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Stamps grid
                      _buildStampsGrid(),

                      const SizedBox(height: 12),

                      // Reward preview
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.trophy,
                              color: Colors.white.withOpacity(0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reward,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return CustomPaint(
      painter: _PatternPainter(color: Colors.white.withOpacity(0.05)),
    );
  }

  Widget _buildStampsGrid() {
    // Calculate grid layout (2 rows max, 6 per row)
    final int maxPerRow = 6;
    final int rows = (stampsRequired / maxPerRow).ceil();
    final int firstRowCount = rows == 1 ? stampsRequired : maxPerRow;
    final int secondRowCount = rows == 2 ? stampsRequired - maxPerRow : 0;

    return Column(
      children: [
        // First row
        _buildStampRow(firstRowCount, 0),
        if (secondRowCount > 0) ...[
          const SizedBox(height: 8),
          _buildStampRow(secondRowCount, firstRowCount),
        ],
      ],
    );
  }

  Widget _buildStampRow(int count, int startIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final stampIndex = startIndex + index;
        final isFilled = stampIndex < currentStamps;

        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.white : Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: isFilled
              ? const Icon(
                  LucideIcons.check,
                  color: Colors.black54,
                  size: 16,
                )
              : null,
        );
      }),
    );
  }
}

/// Background pattern painter
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw subtle circles pattern
    const spacing = 40.0;
    const radius = 20.0;

    for (double x = -radius; x < size.width + radius; x += spacing) {
      for (double y = -radius; y < size.height + radius; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
