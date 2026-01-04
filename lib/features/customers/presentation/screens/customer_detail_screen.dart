import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/models/models.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            l10n.isRtl ? LucideIcons.arrowRight : LucideIcons.arrowLeft,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.get('customer_profile'),
          style: AppTypography.headline,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.userX,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'العميل غير موجود',
                    style: AppTypography.title
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final customer = Customer.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Customer header card
                    _buildHeaderCard(context, customer, l10n),
                    const SizedBox(height: 20),

                    // Stats
                    _buildStatsRow(customer, l10n),
                    const SizedBox(height: 20),

                    // Customer programs / passes
                    _buildProgramsSection(customer, l10n),
                    const SizedBox(height: 20),

                    // Visit history
                    _buildHistorySection(customer, l10n),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(
      BuildContext context, Customer customer, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: customer.name != null && customer.name!.isNotEmpty
                ? Center(
                    child: Text(
                      customer.name![0].toUpperCase(),
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    LucideIcons.user,
                    size: 36,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(height: 16),

          // Name
          if (customer.name != null && customer.name!.isNotEmpty)
            Text(
              customer.name!,
              style: AppTypography.headline.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          const SizedBox(height: 4),

          // Phone
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              customer.phone,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tags
          if (customer.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: customer.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.programPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.label.copyWith(
                            color: AppColors.programPurple,
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Customer customer, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: LucideIcons.calendar,
            value: customer.totalVisits.toString(),
            label: l10n.get('total_visits'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: LucideIcons.trophy,
            value: customer.totalRewards.toString(),
            label: l10n.get('rewards_earned'),
          ),
        ),
      ],
    );
  }

  Widget _buildProgramsSection(Customer customer, AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wallet_passes')
          .where('user_id', isEqualTo: customer.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              children: [
                Icon(LucideIcons.wallet,
                    size: 40, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  'لا يوجد بطاقات ولاء',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

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
                  'بطاقات الولاء',
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final stamps = data['currentStamps'] ?? 0;
                final maxStamps = data['stampsRequired'] ?? 10;
                final hasReward = stamps >= maxStamps;
                final programId = data['program_id'] ?? '';

                return _ProgramItem(
                  passDocId: doc.id,
                  programId: programId,
                  programName: data['programName'] ?? 'برنامج ولاء',
                  stamps: stamps,
                  maxStamps: maxStamps,
                  hasReward: hasReward,
                  customFieldValues: Map<String, String>.from(
                    (data['customFieldValues'] as Map<String, dynamic>?) ?? {},
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistorySection(Customer customer, AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activity_log')
          .where('customerId', isEqualTo: customer.id)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
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
                  l10n.get('visit_history'),
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'لا يوجد سجل زيارات',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                )
              else
                ...snapshot.data!.docs.asMap().entries.map((entry) {
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>;
                  final isLast = entry.key == snapshot.data!.docs.length - 1;

                  return Column(
                    children: [
                      _HistoryItem(
                        type: data['type'] ?? 'stamp',
                        date: (data['timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now(),
                      ),
                      if (!isLast) const Divider(height: 1, indent: 56),
                    ],
                  );
                }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

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
          Icon(icon, size: 24, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.numberMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgramItem extends StatelessWidget {
  final String passDocId;
  final String programId;
  final String programName;
  final int stamps;
  final int maxStamps;
  final bool hasReward;
  final Map<String, String> customFieldValues;

  const _ProgramItem({
    required this.passDocId,
    required this.programId,
    required this.programName,
    required this.stamps,
    required this.maxStamps,
    required this.hasReward,
    this.customFieldValues = const {},
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCustomFieldsDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasReward
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasReward ? LucideIcons.gift : LucideIcons.stamp,
                size: 20,
                color: hasReward ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    programName,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: stamps / maxStamps,
                    backgroundColor: AppColors.inputBackground,
                    valueColor: AlwaysStoppedAnimation(
                      hasReward ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$stamps/$maxStamps',
              style: AppTypography.label.copyWith(
                color: hasReward ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronLeft,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomFieldsDialog(BuildContext context) async {
    if (programId.isEmpty) return;

    // Load program to get custom field definitions
    final programDoc = await FirebaseFirestore.instance
        .collection('programs')
        .doc(programId)
        .get();

    if (!programDoc.exists) return;

    final programData = programDoc.data()!;
    final customFields = (programData['customFields'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .where((f) => f['enabled'] == true)
            .toList() ??
        [];

    if (customFields.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد حقول مخصصة لهذا البرنامج')),
        );
      }
      return;
    }

    // Show dialog to edit custom field values
    if (context.mounted) {
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => _CustomFieldsEditDialog(
          programName: programName,
          customFields: customFields,
          currentValues: customFieldValues,
        ),
      );

      if (result != null && context.mounted) {
        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('wallet_passes')
            .doc(passDocId)
            .update({'customFieldValues': result});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ البيانات ✓'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }
}

class _HistoryItem extends StatelessWidget {
  final String type;
  final DateTime date;

  const _HistoryItem({
    required this.type,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: type == 'stamp'
                  ? AppColors.programOrange.withOpacity(0.1)
                  : AppColors.programPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              type == 'stamp' ? LucideIcons.stamp : LucideIcons.trophy,
              size: 18,
              color: type == 'stamp'
                  ? AppColors.programOrange
                  : AppColors.programPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == 'stamp' ? 'تم إضافة ختم' : 'تم استلام مكافأة',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}

/// Dialog for editing custom field values for a customer's pass
class _CustomFieldsEditDialog extends StatefulWidget {
  final String programName;
  final List<Map<String, dynamic>> customFields;
  final Map<String, String> currentValues;

  const _CustomFieldsEditDialog({
    required this.programName,
    required this.customFields,
    required this.currentValues,
  });

  @override
  State<_CustomFieldsEditDialog> createState() => _CustomFieldsEditDialogState();
}

class _CustomFieldsEditDialogState extends State<_CustomFieldsEditDialog> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final field in widget.customFields) {
      final key = field['key'] as String? ?? '';
      if (key.isNotEmpty) {
        _controllers[key] = TextEditingController(
          text: widget.currentValues[key] ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات العميل',
            style: AppTypography.title,
          ),
          const SizedBox(height: 4),
          Text(
            widget.programName,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.customFields.map((field) {
              final key = field['key'] as String? ?? '';
              final label = field['label'] as String? ?? key;
              final showOnFront = field['showOnFront'] as bool? ?? true;
              
              if (key.isEmpty || !_controllers.containsKey(key)) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _controllers[key],
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: 'أدخل $label',
                    helperText: showOnFront ? 'يظهر على واجهة البطاقة' : 'يظهر في خلف البطاقة',
                    helperStyle: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      showOnFront ? LucideIcons.creditCard : LucideIcons.flipVertical,
                      size: 20,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final values = <String, String>{};
            for (final entry in _controllers.entries) {
              final text = entry.value.text.trim();
              if (text.isNotEmpty) {
                values[entry.key] = text;
              }
            }
            Navigator.pop(context, values);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}