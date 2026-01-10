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
import '../../../shared/widgets/loya_button.dart';

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
      isActive: true,
      customersCount: 156,
      todayVisits: 12,
    ),
    Branch(
      id: '2',
      name: 'فرع جدة',
      address: 'جدة، شارع التحلية',
      manager: 'أحمد محمد',
      isMain: false,
      isActive: true,
      customersCount: 89,
      todayVisits: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final currentPlan = business?.plan ?? 'free';

    // Check branch limits based on plan
    final planConfig = AppConfig.plans[currentPlan];
    final maxBranches = planConfig?.limits.branches ?? 1;
    final canAddMore = maxBranches == -1 || _branches.length < maxBranches;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: EdgeInsets.all(
                isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.get('branches'),
                              style: AppTypography.displaySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_branches.length} ${l10n.get('branches').toLowerCase()}',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        // Only show create button in header on desktop
                        if (!isMobile && canAddMore)
                          SizedBox(
                            width: 180,
                            child: LoyaButton(
                              label: l10n.get('add_branch'),
                              icon: LucideIcons.plus,
                              onPressed: _showAddBranchDialog,
                              height: 44,
                            ),
                          ),
                        if (!isMobile && !canAddMore) _buildUpgradeButton(l10n),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionSmall),

                    // Branches list
                    if (_branches.isEmpty)
                      _buildEmptyState(context, l10n)
                    else
                      _buildBranchesList(context, l10n),

                    // Add bottom spacing for FAB on mobile
                    if (isMobile) const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button for mobile
          if (isMobile && canAddMore)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: LoyaButton(
                  label: l10n.get('add_branch'),
                  icon: LucideIcons.plus,
                  onPressed: _showAddBranchDialog,
                  height: 52,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                LucideIcons.building2,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('no_branches'),
              style: AppTypography.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('branches_desc'),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesList(BuildContext context, AppLocalizations l10n) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _branches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _BranchCard(
          branch: _branches[index],
          onTap: () => _showEditBranchDialog(_branches[index]),
          onDelete: () {
            setState(() {
              _branches.removeAt(index);
            });
          },
        );
      },
    );
  }

  Widget _buildUpgradeButton(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: () {
        showUpgradeDialog(
          context,
          feature: PlanFeature.unlimitedCustomers,
          currentPlan:
              ref.read(currentBusinessProvider).valueOrNull?.plan ?? 'free',
        );
      },
      icon: const Icon(LucideIcons.lock, size: 16),
      label: Text(l10n.get('upgrade')),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.building2,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(l10n.get('add_branch')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.get('branch_name'),
                  prefixIcon: const Icon(LucideIcons.building),
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
                  prefixIcon: const Icon(LucideIcons.mapPin),
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
                  prefixIcon: const Icon(LucideIcons.user),
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
                    isActive: true,
                    customersCount: 0,
                    todayVisits: 0,
                  ));
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.get('add_branch')),
          ),
        ],
      ),
    );
  }

  void _showEditBranchDialog(Branch branch) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: branch.name);
    final addressController = TextEditingController(text: branch.address);
    final managerController = TextEditingController(text: branch.manager ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(LucideIcons.edit, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(l10n.get('edit_branch')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.get('branch_name'),
                  prefixIcon: const Icon(LucideIcons.building),
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
                  prefixIcon: const Icon(LucideIcons.mapPin),
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
                  prefixIcon: const Icon(LucideIcons.user),
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
                  final index = _branches.indexWhere((b) => b.id == branch.id);
                  if (index != -1) {
                    _branches[index] = Branch(
                      id: branch.id,
                      name: nameController.text,
                      address: addressController.text,
                      manager: managerController.text.isNotEmpty
                          ? managerController.text
                          : null,
                      isMain: branch.isMain,
                      isActive: branch.isActive,
                      customersCount: branch.customersCount,
                      todayVisits: branch.todayVisits,
                    );
                  }
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.get('save')),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final Branch branch;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _BranchCard({
    required this.branch,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.softShadow,
            border: Border.all(
              color: branch.isMain
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.borderLight,
              width: branch.isMain ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: branch.isMain
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      branch.isMain ? LucideIcons.crown : LucideIcons.store,
                      size: 20,
                      color: branch.isMain
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: AppTypography.title.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branch.address,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: branch.isActive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      branch.isActive ? l10n.get('active') : l10n.get('paused'),
                      style: AppTypography.labelSmall.copyWith(
                        color: branch.isActive
                            ? AppColors.success
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _StatItem(
                    icon: LucideIcons.users,
                    value: branch.customersCount.toString(),
                    label: l10n.get('customers'),
                  ),
                  const SizedBox(width: 24),
                  _StatItem(
                    icon: LucideIcons.calendarCheck,
                    value: branch.todayVisits.toString(),
                    label: l10n.get('today'),
                  ),
                  if (branch.manager != null) ...[
                    const SizedBox(width: 24),
                    _StatItem(
                      icon: LucideIcons.user,
                      value: branch.manager!,
                      label: l10n.get('manager'),
                      isText: true,
                    ),
                  ],
                  const Spacer(),

                  // Menu button
                  if (!branch.isMain)
                    PopupMenuButton<String>(
                      icon: Icon(
                        LucideIcons.moreVertical,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(LucideIcons.edit,
                                  size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(l10n.get('edit')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trash2,
                                  size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(l10n.get('delete'),
                                  style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    // Main branch indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.star,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            l10n.get('main_branch'),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isText;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: isText
              ? AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                )
              : AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class Branch {
  final String id;
  final String name;
  final String address;
  final String? manager;
  final bool isMain;
  final bool isActive;
  final int customersCount;
  final int todayVisits;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    this.manager,
    this.isMain = false,
    this.isActive = true,
    this.customersCount = 0,
    this.todayVisits = 0,
  });
}
