import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/providers/business_init_provider.dart';
import '../../../shared/widgets/upgrade_prompt.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                l10n.get('settings'),
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.get('settings_subtitle'),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Account section
              _buildSection(
                l10n.get('account'),
                [
                  _SettingsTile(
                    icon: LucideIcons.building2,
                    title: l10n.get('business_profile'),
                    subtitle: l10n.get('business_profile_desc'),
                    onTap: () => context.push('/settings/business'),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.creditCard,
                    title: l10n.get('billing'),
                    subtitle: l10n.get('billing_desc'),
                    trailing: _buildPlanBadge(l10n, ref),
                    onTap: () => context.push('/settings/billing'),
                  ),
                  _buildPremiumSettingsTile(
                    context: context,
                    ref: ref,
                    icon: LucideIcons.users,
                    title: l10n.get('team_members'),
                    subtitle: l10n.get('team_members_desc'),
                    route: '/settings/team',
                    feature: PlanFeature.unlimitedCustomers,
                  ),
                  _SettingsTile(
                    icon: LucideIcons.mapPin,
                    title: l10n.get('branches'),
                    subtitle: 'إدارة فروع ومواقع متجرك',
                    onTap: () => context.push('/settings/locations'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Data section
              _buildSection(
                'البيانات',
                [
                  _SettingsTile(
                    icon: LucideIcons.download,
                    title: 'تصدير البيانات',
                    subtitle: 'تحميل بيانات العملاء والمعاملات',
                    onTap: () => context.push('/settings/export'),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.barChart3,
                    title: 'التحليلات المتقدمة',
                    subtitle: 'رسوم بيانية وإحصائيات تفصيلية',
                    onTap: () => context.push('/analytics/advanced'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Preferences section
              _buildSection(
                l10n.get('preferences'),
                [
                  _SettingsTile(
                    icon: LucideIcons.globe,
                    title: l10n.get('language'),
                    subtitle: l10n.isRtl ? 'العربية' : 'English',
                    onTap: () => _showLanguageDialog(context, ref, l10n),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.bell,
                    title: l10n.get('notifications'),
                    subtitle: l10n.get('notifications_desc'),
                    trailing: Switch.adaptive(
                      value: true,
                      onChanged: (value) {},
                      activeColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Integrations section
              _buildSection(
                l10n.get('integrations'),
                [
                  _SettingsTile(
                    icon: LucideIcons.wallet,
                    title: l10n.get('apple_wallet'),
                    subtitle: l10n.get('apple_wallet_desc'),
                    trailing: _buildConnectedBadge(l10n, true),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.smartphone,
                    title: l10n.get('google_wallet'),
                    subtitle: l10n.get('google_wallet_desc'),
                    trailing: _buildConnectedBadge(l10n, false),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Support section
              _buildSection(
                l10n.get('support'),
                [
                  _SettingsTile(
                    icon: LucideIcons.helpCircle,
                    title: l10n.get('help_center'),
                    subtitle: l10n.get('help_center_desc'),
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.messageCircle,
                    title: l10n.get('contact_support'),
                    subtitle: l10n.get('contact_support_desc'),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Danger zone
              _buildSection(
                l10n.get('danger_zone'),
                [
                  _SettingsTile(
                    icon: LucideIcons.logOut,
                    title: l10n.get('sign_out'),
                    subtitle: l10n.get('sign_out_desc'),
                    isDestructive: true,
                    onTap: () => _showSignOutDialog(context, l10n),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.trash2,
                    title: 'حذف الحساب',
                    subtitle: 'حذف حسابك وجميع بياناتك نهائياً',
                    isDestructive: true,
                    onTap: () => _showDeleteAccountDialog(context, ref, l10n),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Text(
            title,
            style: AppTypography.label.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            children: tiles.asMap().entries.map((entry) {
              final index = entry.key;
              final tile = entry.value;
              return Column(
                children: [
                  tile,
                  if (index < tiles.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanBadge(AppLocalizations l10n, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final currentPlan = business?.plan ?? 'free';
    
    // Plan display names and colors
    final planInfo = {
      'free': {'name': l10n.get('free_plan'), 'color': AppColors.textTertiary},
      'starter': {'name': 'Starter', 'color': AppColors.primary},
      'growth': {'name': 'Growth', 'color': AppColors.success},
      'advanced': {'name': 'Advanced', 'color': AppColors.programPurple},
    };
    
    final info = planInfo[currentPlan] ?? planInfo['free']!;
    final color = info['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        info['name'] as String,
        style: AppTypography.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildConnectedBadge(AppLocalizations l10n, bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.successLight : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isConnected ? l10n.get('connected') : l10n.get('coming_soon'),
        style: AppTypography.captionSmall.copyWith(
          color: isConnected ? AppColors.success : AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPremiumSettingsTile({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required PlanFeature feature,
  }) {
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final userPhone = ref.watch(currentUserPhoneProvider);
    final currentPlan = business?.plan ?? 'free';
    final hasAccess = AppConfig.businessHasFeature(currentPlan, userPhone, feature);
    final requiredPlan = AppConfig.getMinimumPlanForFeature(feature);

    return _SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: hasAccess
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  Icon(LucideIcons.lock, size: 10, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    requiredPlan != null
                        ? AppConfig.plans[requiredPlan]!.nameKey
                            .replaceAll('_plan', '')
                            .toUpperCase()
                        : 'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
      onTap: () {
        if (hasAccess) {
          context.push(route);
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

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(l10n.get('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'العربية',
              isSelected: l10n.isRtl,
              onTap: () {
                Navigator.pop(context);
                // ref.read(localeProvider.notifier).setLocale('ar');
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: 'English',
              isSelected: !l10n.isRtl,
              onTap: () {
                Navigator.pop(context);
                // ref.read(localeProvider.notifier).setLocale('en');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(l10n.get('sign_out')),
        content: Text(l10n.get('sign_out_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              l10n.get('sign_out'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final userContext = ref.read(userContextProvider);
    final business = ref.read(currentBusinessProvider).valueOrNull;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isDeleting = false;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            title: Row(
              children: [
                Icon(LucideIcons.alertTriangle, color: AppColors.error),
                const SizedBox(width: 8),
                Text('حذف الحساب'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل أنت متأكد أنك تريد حذف حسابك؟',
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  userContext?.isOwner == true
                      ? '• سيتم حذف نشاطك التجاري وجميع البيانات المرتبطة به\n• سيتم حذف جميع العملاء والبرامج والمعاملات\n• لا يمكن التراجع عن هذا الإجراء'
                      : '• سيتم إزالتك من الفريق\n• لا يمكن التراجع عن هذا الإجراء',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(context),
                child: Text(l10n.get('cancel')),
              ),
              StatefulBuilder(
                builder: (context, setButtonState) {
                  return TextButton(
                    onPressed: isDeleting
                        ? null
                        : () async {
                            setButtonState(() => isDeleting = true);
                            
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;
                              
                              final service = ref.read(firestoreServiceProvider);
                              final isOwner = userContext?.isOwner ?? true;
                              
                              // Delete user data from Firestore
                              await service.deleteUserAccount(
                                user.uid,
                                business?.id ?? '',
                                isOwner,
                              );
                              
                              // Delete the Firebase Auth user
                              await user.delete();
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                context.go('/login');
                              }
                            } catch (e) {
                              setButtonState(() => isDeleting = false);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('حدث خطأ أثناء حذف الحساب: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                    child: isDeleting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : Text(
                            'حذف الحساب',
                            style: const TextStyle(color: AppColors.error),
                          ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorLight
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color:
                    isDestructive ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                context.l10n.isRtl
                    ? LucideIcons.chevronLeft
                    : LucideIcons.chevronRight,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                LucideIcons.check,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
