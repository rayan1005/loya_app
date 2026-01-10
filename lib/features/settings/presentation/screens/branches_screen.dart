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
  // Dummy data - will be replaced with real data from Firebase
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

    return Stack(
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
                  // Header - same as programs
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

                  // Branches list - same style as programs
                  if (_branches.isEmpty)
                    _buildEmptyState(context, l10n)
                  else
                    _buildBranchesList(context, l10n, isMobile),

                  // Add bottom spacing for FAB on mobile
                  if (isMobile) const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),

        // Floating Action Button for mobile - same as programs
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
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.store,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('no_branches'),
              style: AppTypography.headline.copyWith(
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
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LoyaButton(
                label: l10n.get('add_branch'),
                icon: LucideIcons.plus,
                onPressed: _showAddBranchDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesList(BuildContext context, AppLocalizations l10n, bool isMobile) {
    // Same layout as programs - vertical list on mobile
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _branches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _BranchCard(
        branch: _branches[index],
        onTap: () => _showEditBranchDialog(_branches[index]),
        onDelete: () {
          setState(() {
            _branches.removeAt(index);
          });
        },
      ),
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
              child: Icon(LucideIcons.store,
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

/// Branch Card - EXACTLY like ProgramCard
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
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row - same as program card
              Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.store,
                      size: 20,
                      color: AppColors.primary,
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branch.address,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Status badge - same as program card
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

              // Stats row - same as program card
              Row(
                children: [
                  _StatItem(
                    icon: LucideIcons.users,
                    value: branch.customersCount.toString(),
                    label: l10n.get('customers'),
                  ),
                  const SizedBox(width: 24),
                  _StatItem(
                    icon: LucideIcons.stamp,
                    value: branch.todayVisits.toString(),
                    label: l10n.get('today'),
                  ),
                  const Spacer(),
                  // Location button - like share button in programs
                  Material(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        // TODO: Open location settings
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.mapPin,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              l10n.get('location'),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
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
          style: AppTypography.label.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
