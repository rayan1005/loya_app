import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/l10n/app_localizations.dart';

/// A widget that shows an upgrade prompt when a feature is not available
/// in the current plan. Can be used as a full-screen overlay or inline card.
class UpgradePrompt extends StatelessWidget {
  final PlanFeature feature;
  final String currentPlan;
  final bool isFullScreen;
  final VoidCallback? onClose;

  const UpgradePrompt({
    super.key,
    required this.feature,
    required this.currentPlan,
    this.isFullScreen = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final requiredPlan = AppConfig.getMinimumPlanForFeature(feature);
    final planConfig =
        requiredPlan != null ? AppConfig.plans[requiredPlan] : null;

    if (isFullScreen) {
      return _buildFullScreen(context, l10n, planConfig, requiredPlan);
    }
    return _buildCard(context, l10n, planConfig, requiredPlan);
  }

  Widget _buildCard(BuildContext context, AppLocalizations l10n,
      PlanConfig? planConfig, String? requiredPlan) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock Icon with glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withBlue(230),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.lock,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),

          // Feature name
          Text(
            l10n.get(feature.nameKey),
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Upgrade message
          Text(
            l10n.get('upgrade_to_unlock'),
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          if (planConfig != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.get(planConfig.nameKey),
                style: AppTypography.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Upgrade button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToBilling(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.sparkles, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.get('upgrade_now'),
                    style: AppTypography.button,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreen(BuildContext context, AppLocalizations l10n,
      PlanConfig? planConfig, String? requiredPlan) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
          onPressed: onClose ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large lock with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withBlue(230),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.lock,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Feature name
              Text(
                l10n.get(feature.nameKey),
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                l10n.get('${feature.nameKey}_desc'),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Plan badge
              if (planConfig != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.crown,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.get('available_in')} ${l10n.get(planConfig.nameKey)}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Price display
              if (planConfig != null && planConfig.price > 0)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '€',
                          style: AppTypography.title.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${planConfig.price}',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      l10n.get('per_month_billed_annually'),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Upgrade button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToBilling(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.sparkles, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.get('start_free_trial'),
                        style: AppTypography.button.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Maybe later
              TextButton(
                onPressed: onClose ?? () => Navigator.of(context).pop(),
                child: Text(
                  l10n.get('maybe_later'),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBilling(BuildContext context) {
    context.go('/settings/billing');
  }
}

/// A dialog version of the upgrade prompt
Future<void> showUpgradeDialog(
  BuildContext context, {
  required PlanFeature feature,
  required String currentPlan,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: UpgradePrompt(
        feature: feature,
        currentPlan: currentPlan,
      ),
    ),
  );
}

/// A wrapper widget that shows content or upgrade prompt based on plan
class PlanGatedFeature extends StatelessWidget {
  final PlanFeature feature;
  final String currentPlan;
  final String? businessPhone; // For admin override
  final Widget child;
  final bool showInlinePrompt;

  const PlanGatedFeature({
    super.key,
    required this.feature,
    required this.currentPlan,
    this.businessPhone,
    required this.child,
    this.showInlinePrompt = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess =
        AppConfig.businessHasFeature(currentPlan, businessPhone, feature);

    if (hasAccess) {
      return child;
    }

    if (showInlinePrompt) {
      return UpgradePrompt(
        feature: feature,
        currentPlan: currentPlan,
      );
    }

    // Show locked overlay
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: IgnorePointer(child: child),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => showUpgradeDialog(
              context,
              feature: feature,
              currentPlan: currentPlan,
            ),
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).get('upgrade'),
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A list tile that shows a lock icon for premium features
class PremiumListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final PlanFeature feature;
  final String currentPlan;
  final String? businessPhone; // For admin override
  final VoidCallback onTap;

  const PremiumListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.feature,
    required this.currentPlan,
    this.businessPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess =
        AppConfig.businessHasFeature(currentPlan, businessPhone, feature);
    final requiredPlan = AppConfig.getMinimumPlanForFeature(feature);
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hasAccess
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: hasAccess ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: AppTypography.body.copyWith(
                color:
                    hasAccess ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!hasAccess) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withBlue(230),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.lock, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    requiredPlan != null
                        ? l10n.get(AppConfig.plans[requiredPlan]!.nameKey)
                        : 'PRO',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
        hasAccess ? LucideIcons.chevronRight : LucideIcons.lock,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onTap: () {
        if (hasAccess) {
          onTap();
        } else {
          showUpgradeDialog(
            context,
            feature: feature,
            currentPlan: currentPlan,
          );
        }
      },
    );
  }
}
