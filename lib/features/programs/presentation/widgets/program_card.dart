import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/models/models.dart';

class ProgramCard extends StatelessWidget {
  final LoyaltyProgram program;
  final VoidCallback? onTap;

  const ProgramCard({
    super.key,
    required this.program,
    this.onTap,
  });

  Color get _programColor {
    // Parse color from string or use default
    try {
      if (program.color.startsWith('#')) {
        return Color(
            int.parse(program.color.substring(1), radix: 16) + 0xFF000000);
      }
      return AppColors.primary;
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _programColor;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.softShadow,
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Color indicator & icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.gift,
                      size: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.name,
                          style: AppTypography.title.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          program.description ?? program.rewardDescription,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: program.isActive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      program.isActive
                          ? l10n.get('active')
                          : l10n.get('paused'),
                      style: AppTypography.labelSmall.copyWith(
                        color: program.isActive
                            ? AppColors.success
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Stats row
              Row(
                children: [
                  _StatItem(
                    icon: LucideIcons.users,
                    value: '0', // Will be updated with real count
                    label: l10n.get('customers'),
                  ),
                  const SizedBox(width: 24),
                  _StatItem(
                    icon: LucideIcons.stamp,
                    value: '0', // Will be updated with real count
                    label: l10n.get('today'),
                  ),
                  const Spacer(),
                  // Share button
                  Material(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () =>
                          context.push('/programs/${program.id}/share'),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.qrCode,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'مشاركة',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTypography.label.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
