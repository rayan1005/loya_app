import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../shared/widgets/upgrade_prompt.dart';

class BranchesScreen extends ConsumerStatefulWidget {
  const BranchesScreen({super.key});

  @override
  ConsumerState<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends ConsumerState<BranchesScreen> {
  final List<Branch> _branches = [
    Branch(
      id: '1',
      name: 'الفرع الرئيسي',
      address: 'الرياض، طريق الملك فهد',
      isMain: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final currentPlan = business?.plan ?? 'free';
    
    // Check branch limits based on plan
    final planConfig = AppConfig.plans[currentPlan];
    final maxBranches = planConfig?.limits.branches ?? 1;
    final canAddMore = maxBranches == -1 || _branches.length < maxBranches;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(LucideIcons.building2, size: 28, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.get('branches'), style: AppTypography.headline),
                      const SizedBox(height: 4),
                      Text(
                        l10n.get('branches_desc'),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canAddMore)
                  ElevatedButton.icon(
                    onPressed: _showAddBranchDialog,
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: Text(l10n.get('add_branch')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  )
                else
                  _buildUpgradeButton(l10n),
              ],
            ),
            const SizedBox(height: 16),

            // Plan limit indicator
            _buildLimitIndicator(l10n, maxBranches),
            const SizedBox(height: 24),

            // Branches list
            Expanded(
              child: ListView.builder(
                itemCount: _branches.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBranchCard(_branches[index], l10n),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitIndicator(AppLocalizations l10n, int maxBranches) {
    final isUnlimited = maxBranches == -1;
    final usage = _branches.length;
    final percentage = isUnlimited ? 0.0 : usage / maxBranches;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.building2,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.get('branches'),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isUnlimited ? '$usage / ∞' : '$usage / $maxBranches',
                      style: AppTypography.caption.copyWith(
                        color: percentage >= 1 ? AppColors.error : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (!isUnlimited) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        percentage >= 1 ? AppColors.error : AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: () {
        showUpgradeDialog(
          context,
          feature: PlanFeature.unlimitedCustomers, // Using as placeholder
          currentPlan: ref.read(currentBusinessProvider).valueOrNull?.plan ?? 'free',
        );
      },
      icon: Icon(LucideIcons.lock, size: 16),
      label: Text(l10n.get('upgrade')),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildBranchCard(Branch branch, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
        border: branch.isMain
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: branch.isMain
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              branch.isMain ? LucideIcons.crown : LucideIcons.building,
              color: branch.isMain ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      branch.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (branch.isMain) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.get('main_branch'),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        branch.address,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (branch.manager != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.user,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        branch.manager!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (!branch.isMain)
            PopupMenuButton<String>(
              icon: Icon(
                LucideIcons.moreVertical,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  setState(() {
                    _branches.removeWhere((b) => b.id == branch.id);
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showAddBranchDialog() {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final managerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('add_branch')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.get('branch_name'),
                  prefixIcon: Icon(LucideIcons.building),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: l10n.get('branch_address'),
                  prefixIcon: Icon(LucideIcons.mapPin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: managerController,
                decoration: InputDecoration(
                  labelText: l10n.get('branch_manager'),
                  prefixIcon: Icon(LucideIcons.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  addressController.text.isNotEmpty) {
                setState(() {
                  _branches.add(Branch(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    address: addressController.text,
                    manager: managerController.text.isNotEmpty
                        ? managerController.text
                        : null,
                    isMain: false,
                  ));
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(l10n.get('add_branch')),
          ),
        ],
      ),
    );
  }
}

class Branch {
  final String id;
  final String name;
  final String address;
  final String? manager;
  final bool isMain;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    this.manager,
    this.isMain = false,
  });
}
