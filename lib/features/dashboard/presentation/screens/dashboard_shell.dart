import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/data/providers/business_init_provider.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../shared/widgets/loya_logo.dart';
import '../../../shared/widgets/upgrade_prompt.dart';

class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;

  const DashboardShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  bool _sidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    // Initialize business when dashboard loads
    final businessAsync = ref.watch(businessInitProvider);

    // On mobile, always collapse sidebar
    if (isMobile) {
      _sidebarExpanded = false;
    }

    return businessAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('جاري تحميل بيانات نشاطك التجاري...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertCircle,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('حدث خطأ: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(businessInitProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
      data: (business) => Scaffold(
        backgroundColor: AppColors.background,
        drawer: isMobile ? _buildDrawer(l10n) : null,
        body: SafeArea(
          child: Builder(
            builder: (scaffoldContext) => Row(
              children: [
                // Sidebar (desktop only)
                if (!isMobile) _buildSidebar(l10n),

                // Main content
                Expanded(
                  child: Column(
                    children: [
                      // Top bar
                      _buildTopBar(l10n, isMobile, scaffoldContext),

                      // Content
                      Expanded(
                        child: widget.child,
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

  Widget _buildSidebar(AppLocalizations l10n) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _sidebarExpanded
          ? AppSpacing.sidebarWidth
          : AppSpacing.sidebarCollapsedWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo section
          Container(
            height: AppSpacing.topBarHeight,
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarExpanded ? 20 : 16,
            ),
            alignment: _sidebarExpanded
                ? AlignmentDirectional.centerStart
                : Alignment.center,
            child: _sidebarExpanded
                ? const LoyaLogoHorizontal(height: 28)
                : Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'L',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _NavItem(
                  icon: LucideIcons.layoutDashboard,
                  label: l10n.get('overview'),
                  isSelected: currentRoute == '/',
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: LucideIcons.gift,
                  label: l10n.get('programs'),
                  isSelected: currentRoute.startsWith('/programs'),
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/programs'),
                ),
                _NavItem(
                  icon: LucideIcons.users,
                  label: l10n.get('customers'),
                  isSelected: currentRoute.startsWith('/customers'),
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/customers'),
                ),
                _NavItem(
                  icon: LucideIcons.activity,
                  label: l10n.get('activity'),
                  isSelected: currentRoute == '/activity',
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/activity'),
                ),
                _NavItem(
                  icon: LucideIcons.barChart3,
                  label: l10n.get('analytics'),
                  isSelected: currentRoute.startsWith('/analytics'),
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/analytics'),
                ),
                const SizedBox(height: 16),
                if (_sidebarExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'أدوات',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                const SizedBox(height: 8),
                _NavItem(
                  icon: LucideIcons.stamp,
                  label: 'ختم البطاقات',
                  isSelected: currentRoute == '/stamper',
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/stamper'),
                ),
                _NavItem(
                  icon: LucideIcons.send,
                  label: 'الرسائل',
                  isSelected: currentRoute == '/messages',
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/messages'),
                ),
                const SizedBox(height: 16),
                if (_sidebarExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'التسويق',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                const SizedBox(height: 8),
                _buildPremiumNavItem(
                  context: context,
                  icon: LucideIcons.gift,
                  label: l10n.get('referral_program'),
                  route: '/referral',
                  currentRoute: currentRoute,
                  feature: PlanFeature.referralProgram,
                ),
                _buildPremiumNavItem(
                  context: context,
                  icon: LucideIcons.zap,
                  label: l10n.get('automation'),
                  route: '/automation',
                  currentRoute: currentRoute,
                  feature: PlanFeature.automatedPush,
                ),
                const SizedBox(height: 24),
                if (_sidebarExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(color: AppColors.divider.withOpacity(0.5)),
                  ),
                const SizedBox(height: 8),
                _NavItem(
                  icon: LucideIcons.settings,
                  label: l10n.get('settings'),
                  isSelected: currentRoute.startsWith('/settings'),
                  isExpanded: _sidebarExpanded,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),

          // Collapse button
          Padding(
            padding: const EdgeInsets.all(12),
            child: _NavItem(
              icon: _sidebarExpanded
                  ? (l10n.isRtl
                      ? LucideIcons.panelRightClose
                      : LucideIcons.panelLeftClose)
                  : (l10n.isRtl
                      ? LucideIcons.panelRightOpen
                      : LucideIcons.panelLeftOpen),
              label: '',
              isSelected: false,
              isExpanded: _sidebarExpanded,
              onTap: () {
                setState(() {
                  _sidebarExpanded = !_sidebarExpanded;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required String currentRoute,
    required PlanFeature feature,
  }) {
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final userPhone = ref.watch(currentUserPhoneProvider);
    final currentPlan = business?.plan ?? 'free';
    final hasAccess =
        AppConfig.businessHasFeature(currentPlan, userPhone, feature);
    final isSelected = currentRoute == route;

    return _NavItemWithBadge(
      icon: icon,
      label: label,
      isSelected: isSelected,
      isExpanded: _sidebarExpanded,
      isLocked: !hasAccess,
      onTap: () {
        if (hasAccess) {
          context.go(route);
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

  Widget _buildDrawer(AppLocalizations l10n) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Logo
            Container(
              height: AppSpacing.topBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: AlignmentDirectional.centerStart,
              child: const LoyaLogoHorizontal(height: 28),
            ),

            const Divider(height: 1),

            // Navigation
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _NavItem(
                    icon: LucideIcons.layoutDashboard,
                    label: l10n.get('overview'),
                    isSelected: currentRoute == '/',
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/');
                    },
                  ),
                  _NavItem(
                    icon: LucideIcons.gift,
                    label: l10n.get('programs'),
                    isSelected: currentRoute.startsWith('/programs'),
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/programs');
                    },
                  ),
                  _NavItem(
                    icon: LucideIcons.users,
                    label: l10n.get('customers'),
                    isSelected: currentRoute.startsWith('/customers'),
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customers');
                    },
                  ),
                  _NavItem(
                    icon: LucideIcons.activity,
                    label: l10n.get('activity'),
                    isSelected: currentRoute == '/activity',
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/activity');
                    },
                  ),
                  _NavItem(
                    icon: LucideIcons.barChart3,
                    label: l10n.get('analytics'),
                    isSelected: currentRoute == '/analytics',
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/analytics');
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'أدوات',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                  _NavItem(
                    icon: LucideIcons.stamp,
                    label: 'ختم البطاقات',
                    isSelected: currentRoute == '/stamper',
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/stamper');
                    },
                  ),
                  _NavItem(
                    icon: LucideIcons.send,
                    label: 'الرسائل',
                    isSelected: currentRoute == '/messages',
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/messages');
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'التسويق',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                  _buildMobileDrawerPremiumItem(
                    l10n: l10n,
                    icon: LucideIcons.gift,
                    label: l10n.get('referral_program'),
                    route: '/referral',
                    currentRoute: currentRoute,
                    feature: PlanFeature.referralProgram,
                  ),
                  _buildMobileDrawerPremiumItem(
                    l10n: l10n,
                    icon: LucideIcons.zap,
                    label: l10n.get('automation'),
                    route: '/automation',
                    currentRoute: currentRoute,
                    feature: PlanFeature.automatedPush,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _NavItem(
                    icon: LucideIcons.settings,
                    label: l10n.get('settings'),
                    isSelected: currentRoute.startsWith('/settings'),
                    isExpanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawerPremiumItem({
    required AppLocalizations l10n,
    required IconData icon,
    required String label,
    required String route,
    required String currentRoute,
    required PlanFeature feature,
  }) {
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final userPhone = ref.watch(currentUserPhoneProvider);
    final currentPlan = business?.plan ?? 'free';
    final hasAccess =
        AppConfig.businessHasFeature(currentPlan, userPhone, feature);
    final isSelected = currentRoute == route;

    return _NavItem(
      icon: icon,
      label: label,
      isSelected: isSelected,
      isExpanded: true,
      trailing: !hasAccess
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        if (hasAccess) {
          context.go(route);
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

  Widget _buildTopBar(AppLocalizations l10n, bool isMobile, BuildContext scaffoldContext) {
    return Container(
      height: AppSpacing.topBarHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Menu button (mobile)
          if (isMobile)
            IconButton(
              icon: const Icon(LucideIcons.menu),
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
              color: AppColors.textPrimary,
            ),

          // Quick stamp button
          if (!isMobile) ...[
            _QuickActionButton(
              icon: LucideIcons.stamp,
              label: l10n.get('add_stamp'),
              onTap: () => context.push('/stamp'),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              icon: LucideIcons.userPlus,
              label: l10n.get('new_customer'),
              isPrimary: false,
              onTap: () => context.push('/customers'),
            ),
          ],

          const Spacer(),

          // Language toggle
          IconButton(
            icon: Text(
              l10n.isRtl ? 'EN' : 'ع',
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            tooltip: l10n.get('language'),
          ),

          const SizedBox(width: 8),

          // Notifications
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: 8),

          // Profile
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              LucideIcons.user,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation item widget
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget? trailing;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isExpanded ? '' : label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 12 : 0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                if (isExpanded && label.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick action button in top bar
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.isPrimary = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.inputBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.buttonSmall.copyWith(
                  color: isPrimary ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item with premium badge
class _NavItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final bool isLocked;
  final VoidCallback onTap;

  const _NavItemWithBadge({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isExpanded ? '' : label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 12 : 0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isLocked
                      ? AppColors.textTertiary
                      : (isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary),
                ),
                if (isExpanded && label.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body.copyWith(
                        color: isLocked
                            ? AppColors.textTertiary
                            : (isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withBlue(230),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.lock,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
