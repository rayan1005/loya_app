import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/activity_list.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    // Watch real data from Firebase
    final statsAsync = ref.watch(dashboardStatsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(
          isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(context, l10n),
              const SizedBox(height: AppSpacing.sectionSmall),

              // Stats Grid - use real data
              statsAsync.when(
                loading: () => _buildStatsGridLoading(isMobile),
                error: (_, __) =>
                    _buildStatsGrid(context, l10n, isMobile, 0, 0, 0, 0),
                data: (stats) => _buildStatsGrid(
                  context,
                  l10n,
                  isMobile,
                  stats['totalCustomers'] ?? 0,
                  stats['activePrograms'] ?? 0,
                  stats['stampsToday'] ?? 0,
                  stats['rewardsIssued'] ?? 0,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionSmall),

              // Quick Actions (mobile)
              if (isMobile) ...[
                _buildMobileQuickActions(context, l10n),
                const SizedBox(height: AppSpacing.sectionSmall),
              ],

              // Content Row
              if (isMobile)
                ..._buildMobileContent(context, l10n)
              else
                _buildDesktopContent(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.get('good_morning');
    } else if (hour < 17) {
      greeting = l10n.get('good_afternoon');
    } else {
      greeting = l10n.get('good_evening');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTypography.displaySmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.get('today_summary'),
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGridLoading(bool isMobile) {
    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    return Row(
      children: List.generate(
          4,
          (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
              )),
    );
  }

  Widget _buildStatsGrid(
      BuildContext context,
      AppLocalizations l10n,
      bool isMobile,
      int totalCustomers,
      int activePrograms,
      int stampsToday,
      int rewardsIssued) {
    final stats = [
      StatData(
        label: l10n.get('total_customers'),
        value: '$totalCustomers',
        icon: LucideIcons.users,
        color: AppColors.programBlue,
      ),
      StatData(
        label: l10n.get('active_programs'),
        value: '$activePrograms',
        icon: LucideIcons.gift,
        color: AppColors.programGreen,
      ),
      StatData(
        label: l10n.get('stamps_today'),
        value: '$stampsToday',
        icon: LucideIcons.stamp,
        color: AppColors.programOrange,
      ),
      StatData(
        label: l10n.get('rewards_issued'),
        value: '$rewardsIssued',
        icon: LucideIcons.trophy,
        color: AppColors.programPurple,
      ),
    ];

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) => StatCard(data: stats[index]),
      );
    }

    return Row(
      children: stats
          .map((stat) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: stats.last != stat ? 16 : 0,
                  ),
                  child: StatCard(data: stat),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMobileQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: LucideIcons.stamp,
            label: l10n.get('add_stamp'),
            color: AppColors.primary,
            onTap: () => context.push('/stamp'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: LucideIcons.userPlus,
            label: l10n.get('new_customer'),
            color: AppColors.programGreen,
            onTap: () => context.push('/customers'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Activity
        Expanded(
          flex: 2,
          child: _ContentCard(
            title: l10n.get('recent_activity'),
            child: const ActivityList(),
          ),
        ),
        const SizedBox(width: 24),
        // Quick Actions / Active Program
        Expanded(
          child: Column(
            children: [
              _ContentCard(
                title: l10n.get('quick_actions'),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: LucideIcons.stamp,
                      label: l10n.get('add_stamp'),
                      onTap: () => context.push('/stamp'),
                    ),
                    const Divider(height: 1),
                    _ActionTile(
                      icon: LucideIcons.userPlus,
                      label: l10n.get('new_customer'),
                      onTap: () => context.push('/customers'),
                    ),
                    const Divider(height: 1),
                    _ActionTile(
                      icon: LucideIcons.plus,
                      label: l10n.get('create_program'),
                      onTap: () => context.push('/programs/create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMobileContent(
      BuildContext context, AppLocalizations l10n) {
    return [
      _ContentCard(
        title: l10n.get('recent_activity'),
        child: const ActivityList(maxItems: 5),
      ),
    ];
  }
}

/// Quick action card for mobile
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.buttonSmall.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Content card wrapper
class _ContentCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ContentCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: AppTypography.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Action tile
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                context.l10n.isRtl
                    ? LucideIcons.chevronLeft
                    : LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
