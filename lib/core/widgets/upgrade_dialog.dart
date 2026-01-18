import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../subscription/models/models.dart';

/// Shows an upgrade dialog when a limit is reached
class UpgradeDialog extends StatelessWidget {
  final String title;
  final String message;
  final PlanType suggestedPlan;
  final IconData? icon;

  const UpgradeDialog({
    super.key,
    required this.title,
    required this.message,
    this.suggestedPlan = PlanType.pro,
    this.icon,
  });

  /// Show the dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    PlanType suggestedPlan = PlanType.pro,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => UpgradeDialog(
        title: title,
        message: message,
        suggestedPlan: suggestedPlan,
        icon: icon,
      ),
    );
  }

  /// Pre-built dialogs for common limits
  
  static Future<void> showCustomerLimit(BuildContext context, int limit) {
    return show(
      context,
      title: 'وصلت للحد الأقصى!',
      message: 'لقد وصلت لحد $limit عميل في الباقة المجانية.\nقم بالترقية لإضافة المزيد من العملاء.',
      icon: LucideIcons.users,
    );
  }

  static Future<void> showStampLimit(BuildContext context, int limit) {
    return show(
      context,
      title: 'استنفدت الأختام الشهرية!',
      message: 'لقد استخدمت $limit ختم هذا الشهر.\nقم بالترقية للحصول على أختام أكثر.',
      icon: LucideIcons.stamp,
    );
  }

  static Future<void> showProgramLimit(BuildContext context, int limit) {
    return show(
      context,
      title: 'لا يمكن إنشاء برنامج جديد',
      message: 'لقد وصلت لحد $limit برنامج في الباقة المجانية.\nقم بالترقية لإنشاء برامج أكثر.',
      icon: LucideIcons.award,
    );
  }

  static Future<void> showTeamMemberLimit(BuildContext context, int limit) {
    return show(
      context,
      title: 'لا يمكن إضافة عضو جديد',
      message: 'لقد وصلت لحد $limit عضو في الفريق.\nقم بالترقية لإضافة المزيد.',
      icon: LucideIcons.userPlus,
    );
  }

  static Future<void> showLocationLimit(BuildContext context, int limit) {
    return show(
      context,
      title: 'لا يمكن إضافة فرع جديد',
      message: 'لقد وصلت لحد $limit فرع في الباقة الحالية.\nقم بالترقية لإضافة المزيد.',
      icon: LucideIcons.mapPin,
    );
  }

  static Future<void> showPushNotificationLimit(BuildContext context, int limit) {
    return show(
      context,
      title: 'استنفدت الإشعارات الشهرية',
      message: 'لقد أرسلت $limit إشعار هذا الشهر.\nقم بالترقية لإرسال المزيد.',
      icon: LucideIcons.bell,
    );
  }

  static Future<void> showAutomationLimit(BuildContext context, int limit) {
    return show(
      context,
      title: 'لا يمكن إنشاء قاعدة جديدة',
      message: 'لقد وصلت لحد $limit قاعدة أتمتة.\nقم بالترقية لإنشاء المزيد.',
      icon: LucideIcons.zap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? LucideIcons.alertTriangle,
                color: AppColors.warning,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: AppTypography.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Suggested plan info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.crown, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'باقة ${suggestedPlan.displayNameAr}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '\$${suggestedPlan.monthlyPrice.toStringAsFixed(0)}/شهر',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'لاحقاً',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/settings/upgrade', extra: {
                        'highlightedPlan': suggestedPlan.name,
                        'limitReachedMessage': message,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'ترقية الآن',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small upgrade banner to show in settings or dashboard
class UpgradeBanner extends StatelessWidget {
  final PlanType currentPlan;
  final VoidCallback? onTap;

  const UpgradeBanner({
    super.key,
    this.currentPlan = PlanType.free,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (currentPlan == PlanType.business) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap ?? () => context.push('/settings/upgrade'),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.crown, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPlan == PlanType.free
                        ? 'ترقية إلى Pro'
                        : 'ترقية إلى Business',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'احصل على المزيد من العملاء والمميزات',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronLeft,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
