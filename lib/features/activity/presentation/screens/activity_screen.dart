import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/models/models.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;
    final businessId = ref.watch(currentBusinessIdProvider);
    final horizontalPadding =
        isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding;

    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                l10n.get('activity'),
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.get('activity_subtitle'),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Filters
              _buildFilters(l10n),
              const SizedBox(height: 16),

              // Activity list from Firestore
              if (businessId == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(LucideIcons.logIn,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        Text(
                          'يرجى تسجيل الدخول',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildActivityList(businessId, l10n),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(String businessId, AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activity_log')
          .where('businessId', isEqualTo: businessId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(LucideIcons.inbox,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.get('no_activity'),
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أضف أختام لعملائك لرؤية النشاط هنا',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          );
        }

        // Filter activities based on selected filter
        var activities = snapshot.data!.docs;
        if (_selectedFilter != 'all') {
          final filterType = _selectedFilter == 'stamps'
              ? 'stamp'
              : _selectedFilter == 'rewards'
                  ? 'reward'
                  : 'new_customer';
          activities = activities.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['type'] == filterType;
          }).toList();
        }

        if (activities.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(LucideIcons.inbox,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد نشاط من هذا النوع',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        String? lastDateHeader;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: activities.map((doc) {
            final activity = ActivityLog.fromFirestore(doc);
            final dateHeader = _formatDateHeader(activity.timestamp, l10n);
            final showHeader = dateHeader != lastDateHeader;
            lastDateHeader = dateHeader;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHeader) ...[
                  const SizedBox(height: 16),
                  Text(
                    dateHeader,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _ActivityCard(activity: activity),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.get('all'),
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.get('stamps'),
            isSelected: _selectedFilter == 'stamps',
            onTap: () => setState(() => _selectedFilter = 'stamps'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.get('rewards'),
            isSelected: _selectedFilter == 'rewards',
            onTap: () => setState(() => _selectedFilter = 'rewards'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.get('new_customers'),
            isSelected: _selectedFilter == 'new_customers',
            onTap: () => setState(() => _selectedFilter = 'new_customers'),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.get('today');
    } else if (dateOnly == yesterday) {
      return l10n.get('yesterday');
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected ? null : AppColors.softShadow,
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityLog activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(),
              size: 24,
              color: _getIconBackgroundColor(),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.programName,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Time & Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(activity.timestamp),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              if (activity.stampCount != null && activity.maxStamps != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getProgressColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${activity.stampCount}/${activity.maxStamps}',
                    style: AppTypography.captionSmall.copyWith(
                      color: _getProgressColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (activity.type) {
      case ActivityType.stamp:
        return LucideIcons.stamp;
      case ActivityType.reward:
        return LucideIcons.gift;
      case ActivityType.newCustomer:
        return LucideIcons.userPlus;
    }
  }

  Color _getIconBackgroundColor() {
    switch (activity.type) {
      case ActivityType.stamp:
        return AppColors.programOrange;
      case ActivityType.reward:
        return AppColors.programPurple;
      case ActivityType.newCustomer:
        return AppColors.primary;
    }
  }

  Color _getProgressColor() {
    final stamps = activity.stampCount ?? 0;
    final max = activity.maxStamps ?? 10;
    if (stamps >= max) {
      return AppColors.success;
    }
    return AppColors.primary;
  }

  String _getTitle() {
    final name = activity.customerName ?? activity.customerPhone;
    switch (activity.type) {
      case ActivityType.reward:
        return '$name 🎉';
      default:
        return name;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}د';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}س';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
