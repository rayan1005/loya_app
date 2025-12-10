import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class StampCardWidget extends StatelessWidget {
  const StampCardWidget({
    super.key,
    required this.title,
    required this.stampCount,
    required this.filledStamps,
    required this.statusPrimary,
    required this.statusSecondary,
    required this.backgroundColor,
    this.foregroundColor,
    this.labelColor,
    this.onTap,
    this.onDetails,
    this.width,
    this.height,
  });

  final String title;
  final int stampCount;
  final int filledStamps;
  final String statusPrimary;
  final String statusSecondary;
  final Color backgroundColor;
  final Color? foregroundColor;
  final Color? labelColor;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final total = stampCount.clamp(0, 12);
    final filled = math.min(filledStamps, total);
    final cardWidth =
        width ?? math.min(MediaQuery.sizeOf(context).width * 0.9, 420.0);
    final cardHeight = height ?? 220.0;
    final fg = foregroundColor ?? Colors.white;
    final muted = (foregroundColor ?? Colors.white).withOpacity(0.25);
    final tagColor = labelColor ?? fg;

    return InkWell(
      onTap: onTap ?? onDetails,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Color(0x1A000000),
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w800),
                    color: fg,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(statusPrimary, fg),
                _pill(statusSecondary, tagColor),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rows = total > 6 ? 2 : 1;
                  final row1 = math.min(total, 6);
                  final row2 = total - row1;
                  const spacing = 8.0;
                  final rowWidth = constraints.maxWidth;
                  final maxPerRow = rows == 2 ? 6 : row1;
                  final diameter = ((rowWidth - (maxPerRow - 1) * spacing) /
                          math.max(maxPerRow, 1))
                      .clamp(16.0, 32.0);
                  final rowSpacing = rows == 2 ? 12.0 : 0.0;

                  Widget buildRow(int count, int offset) {
                    if (count <= 0) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(count, (index) {
                        final stampIndex = offset + index;
                        final isFilled = stampIndex < filled;
                        return Padding(
                          padding: EdgeInsets.only(
                              right: index == count - 1 ? 0 : spacing),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            opacity: 1,
                            child: CircleAvatar(
                              radius: diameter / 2,
                              backgroundColor: isFilled ? fg : muted,
                              child: Icon(
                                isFilled ? Icons.check : Icons.star,
                                size: diameter / 2,
                                color: isFilled ? backgroundColor : fg,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }

                  return Column(
                    mainAxisAlignment: rows == 1
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceEvenly,
                    children: [
                      buildRow(row1, 0),
                      if (rows == 2) SizedBox(height: rowSpacing),
                      if (rows == 2) buildRow(row2, row1),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FFButtonWidget(
                onPressed: onDetails ?? onTap,
                text: 'View details',
                options: FFButtonOptions(
                  height: 44,
                  color: Colors.white,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                        color: backgroundColor,
                      ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
