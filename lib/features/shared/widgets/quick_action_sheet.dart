import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Data class to hold scanned customer info
class ScannedCustomerData {
  final String customerId;
  final String? programId;
  final String? customerName;
  final String? programName;
  final int? currentStamps;
  final int? stampsRequired;
  final int? availableRewards;

  const ScannedCustomerData({
    required this.customerId,
    this.programId,
    this.customerName,
    this.programName,
    this.currentStamps,
    this.stampsRequired,
    this.availableRewards,
  });

  bool get hasReward => (availableRewards ?? 0) > 0;
  
  String get stampProgress {
    if (currentStamps != null && stampsRequired != null) {
      return '$currentStamps / $stampsRequired';
    }
    return '-- / --';
  }
}

/// Provider to hold the scanned customer data (from deep link or manual scan)
final scannedCustomerProvider = StateProvider<ScannedCustomerData?>((ref) => null);

/// Provider to control sheet visibility
final quickActionSheetVisibleProvider = StateProvider<bool>((ref) => false);

/// Quick Action Sheet - Floating card for stamp/redeem actions
/// Shows on app open or after deep link scan
class QuickActionSheet extends ConsumerWidget {
  final VoidCallback? onStampPressed;
  final VoidCallback? onRedeemPressed;
  final VoidCallback? onClose;

  const QuickActionSheet({
    super.key,
    this.onStampPressed,
    this.onRedeemPressed,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannedCustomer = ref.watch(scannedCustomerProvider);
    final hasCustomer = scannedCustomer != null;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: hasCustomer
                      ? _buildCustomerInfo(scannedCustomer)
                      : _buildNoCustomerHeader(),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(quickActionSheetVisibleProvider.notifier).state = false;
                    ref.read(scannedCustomerProvider.notifier).state = null;
                    onClose?.call();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                // ADD STAMP Button
                _ActionButton(
                  icon: LucideIcons.plus,
                  label: hasCustomer ? 'إضافة ختم' : 'إضافة ختم',
                  subtitle: hasCustomer ? null : 'افتح الكاميرا للمسح',
                  color: AppColors.primary,
                  onPressed: onStampPressed,
                ),

                const SizedBox(height: 12),

                // Divider with "OR"
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),

                const SizedBox(height: 12),

                // REDEEM Button
                _ActionButton(
                  icon: LucideIcons.gift,
                  label: 'استبدال مكافأة',
                  subtitle: hasCustomer 
                      ? (scannedCustomer.hasReward 
                          ? '${scannedCustomer.availableRewards} مكافأة متاحة' 
                          : 'لا توجد مكافآت')
                      : 'افتح الكاميرا للمسح',
                  color: AppColors.success,
                  enabled: !hasCustomer || scannedCustomer.hasReward,
                  onPressed: onRedeemPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCustomerHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراء سريع',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'اختر الإجراء ثم امسح رمز العميل',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(ScannedCustomerData customer) {
    return Row(
      children: [
        // Customer Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              customer.customerName?.isNotEmpty == true
                  ? customer.customerName![0].toUpperCase()
                  : '👤',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.customerName ?? 'عميل',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (customer.programName != null) ...[
                    Icon(
                      LucideIcons.tag,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.programName!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    LucideIcons.stamp,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    customer.stampProgress,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Styled action button for the quick action sheet
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    this.enabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppColors.disabled;
    final textColor = enabled ? Colors.white : AppColors.textDisabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: textColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.titleMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronLeft,
                  color: textColor.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay widget to show the quick action sheet as a floating card
class QuickActionOverlay extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onStampPressed;
  final VoidCallback? onRedeemPressed;

  const QuickActionOverlay({
    super.key,
    required this.child,
    this.onStampPressed,
    this.onRedeemPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(quickActionSheetVisibleProvider);

    return Stack(
      children: [
        child,
        
        // Floating Quick Action Sheet
        if (isVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: QuickActionSheet(
                onStampPressed: onStampPressed,
                onRedeemPressed: onRedeemPressed,
              ),
            ),
          ),
      ],
    );
  }
}

/// Show the quick action sheet as a modal bottom sheet
Future<T?> showQuickActionSheet<T>(
  BuildContext context, {
  ScannedCustomerData? customer,
  required VoidCallback onStampPressed,
  required VoidCallback onRedeemPressed,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        // Set customer data if provided
        if (customer != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(scannedCustomerProvider.notifier).state = customer;
          });
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: QuickActionSheet(
            onStampPressed: () {
              Navigator.of(context).pop();
              onStampPressed();
            },
            onRedeemPressed: () {
              Navigator.of(context).pop();
              onRedeemPressed();
            },
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      },
    ),
  );
}
