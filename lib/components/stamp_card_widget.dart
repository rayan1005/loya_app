import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/wallet_stamp_grid.dart';

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
    this.stampIconUrl,
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
  final String? stampIconUrl;

  @override
  Widget build(BuildContext context) {
    final total = stampCount.clamp(0, 12);
    final filled = math.min(filledStamps, total);
    final cardWidth =
        width ?? math.min(MediaQuery.sizeOf(context).width * 0.9, 420.0);
    final cardHeight = height ?? 220.0;
    final fg = foregroundColor ?? Colors.white;
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
              child: WalletStampGrid(
                total: total,
                filled: filled,
                activeColor: fg,
                inactiveColor: fg.withOpacity(0.35),
                borderColor: tagColor,
                stampIconUrl: stampIconUrl ?? '',
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
