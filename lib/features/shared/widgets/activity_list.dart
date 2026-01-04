import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/data/providers/data_providers.dart';

/// Activity item data
class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final ActivityType type;
  final DateTime timestamp;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
  });
}

enum ActivityType {
  stamp,
  reward,
  customer,
  program,
}

/// Activity list widget - uses real Firestore data
class ActivityList extends ConsumerWidget {
  final int? maxItems;

  const ActivityList({
    super.key,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessId = ref.watch(currentBusinessIdProvider);

    if (businessId == null) {
      return _buildEmptyState();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activity_log')
          .where('businessId', isEqualTo: businessId)
          .orderBy('timestamp', descending: true)
          .limit(maxItems ?? 20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final activities = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final type = data['type']?.toString() ?? 'stamp';

          ActivityType activityType;
          String title;

          switch (type) {
            case 'reward':
              activityType = ActivityType.reward;
              title = 'تم استلام مكافأة';
              break;
            case 'customer':
              activityType = ActivityType.customer;
              title = 'عميل جديد';
              break;
            case 'program':
              activityType = ActivityType.program;
              title = 'برنامج جديد';
              break;
            default:
              activityType = ActivityType.stamp;
              title = 'تم إضافة ختم';
          }

          return ActivityItem(
            id: doc.id,
            title: title,
            subtitle: data['customerPhone']?.toString() ??
                data['customerName']?.toString() ??
                '',
            type: activityType,
            timestamp:
                (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 0),
          itemCount: activities.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 60),
          itemBuilder: (context, index) {
            final item = activities[index];
            return _ActivityTile(item: item);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.activity,
              size: 48,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد نشاط حتى الآن',
              style: AppTypography.body.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(),
              size: 18,
              color: _getColor(),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    item.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Time
          Text(
            _formatTime(item.timestamp),
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (item.type) {
      case ActivityType.stamp:
        return LucideIcons.stamp;
      case ActivityType.reward:
        return LucideIcons.trophy;
      case ActivityType.customer:
        return LucideIcons.userPlus;
      case ActivityType.program:
        return LucideIcons.gift;
    }
  }

  Color _getColor() {
    switch (item.type) {
      case ActivityType.stamp:
        return AppColors.programOrange;
      case ActivityType.reward:
        return AppColors.programPurple;
      case ActivityType.customer:
        return AppColors.programGreen;
      case ActivityType.program:
        return AppColors.programBlue;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} د';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} س';
    } else {
      return 'منذ ${diff.inDays} ي';
    }
  }
}
