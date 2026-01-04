import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../shared/widgets/upgrade_prompt.dart';
import '../../../shared/widgets/loya_button.dart';

class TeamMembersScreen extends ConsumerStatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  ConsumerState<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends ConsumerState<TeamMembersScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final currentPlan = business?.plan ?? 'free';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    // Team members require at least Starter plan
    // For free plan, show upgrade prompt
    final hasAccess = currentPlan != 'free';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(LucideIcons.users, size: 28, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.get('team_members'),
                              style: AppTypography.headline),
                          const SizedBox(height: 4),
                          Text(
                            l10n.get('team_members_desc'),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Desktop: show button in header
                    if (hasAccess && !isMobile)
                      SizedBox(
                        width: 180,
                        child: LoyaButton(
                          label: l10n.get('add_team_member'),
                          icon: LucideIcons.userPlus,
                          onPressed: _showInviteDialog,
                          height: 44,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: hasAccess
                      ? _buildTeamList(l10n)
                      : Center(
                          child: UpgradePrompt(
                            feature: PlanFeature.unlimitedCustomers,
                            currentPlan: currentPlan,
                          ),
                        ),
                ),

                // Add bottom spacing for FAB on mobile
                if (isMobile && hasAccess) const SizedBox(height: 80),
              ],
            ),
          ),
          // Floating Action Button for mobile
          if (isMobile && hasAccess)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: LoyaButton(
                  label: l10n.get('add_team_member'),
                  icon: LucideIcons.userPlus,
                  onPressed: _showInviteDialog,
                  height: 52,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamList(AppLocalizations l10n) {
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final currentUser = FirebaseAuth.instance.currentUser;
    final ownerName = business?.nameAr ?? business?.nameEn ?? 'صاحب المتجر';
    final ownerPhone = currentUser?.phoneNumber ?? business?.phone ?? '';

    return Column(
      children: [
        // Current user (Owner)
        _buildMemberCard(
          name: ownerName,
          phone: ownerPhone,
          role: l10n.get('role_owner'),
          isOwner: true,
        ),
        const SizedBox(height: 16),

        // Team members from Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('businesses')
                .doc(business?.id)
                .collection('team_members')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Team members error: [38;5;5m${snapshot.error}[0m');
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.alertCircle,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('حدث خطأ في تحميل الفريق'),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', style: AppTypography.caption),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final members = snapshot.data?.docs ?? [];

              if (members.isEmpty) {
                return _buildEmptyState(l10n);
              }

              return ListView.separated(
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = members[index].data() as Map<String, dynamic>;
                  return _buildMemberCard(
                    name: member['name'] ?? member['phone'] ?? 'عضو',
                    phone: member['phone'] ?? '',
                    role: _getRoleLabel(member['role'] ?? 'cashier', l10n),
                    isOwner: false,
                    memberId: members[index].id,
                    memberData: member,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getRoleLabel(String role, AppLocalizations l10n) {
    switch (role) {
      case 'manager':
        return l10n.get('role_manager');
      case 'cashier':
        return l10n.get('role_cashier');
      default:
        return role;
    }
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.users,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا يوجد أعضاء في الفريق',
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف أعضاء فريقك لمساعدتك في إدارة المتجر',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: LoyaButton(
              label: l10n.get('add_team_member'),
              icon: LucideIcons.userPlus,
              onPressed: _showInviteDialog,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard({
    required String name,
    required String phone,
    required String role,
    bool isOwner = false,
    String? memberId,
    Map<String, dynamic>? memberData,
  }) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: isOwner
                ? AppColors.success.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            child: Icon(
              isOwner ? LucideIcons.crown : LucideIcons.user,
              size: 24,
              color: isOwner ? AppColors.success : AppColors.primary,
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
                    Flexible(
                      child: Text(
                        name,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOwner
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        role,
                        style: AppTypography.caption.copyWith(
                          color:
                              isOwner ? AppColors.success : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (!isOwner && memberId != null)
            PopupMenuButton<String>(
              icon: Icon(
                LucideIcons.moreVertical,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) async {
                if (value == 'remove') {
                  _showRemoveConfirmation(
                      memberId, memberData?['name'] ?? phone, l10n);
                } else if (value == 'edit') {
                  _showEditDialog(memberId, memberData ?? {}, l10n);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.edit,
                          size: 18, color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(l10n.get('edit')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(l10n.get('delete'),
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(
      String memberId, String memberName, AppLocalizations l10n) {
    final business = ref.read(currentBusinessProvider).valueOrNull;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('delete')),
        content: Text('هل تريد إزالة $memberName من الفريق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('businesses')
                    .doc(business?.id)
                    .collection('team_members')
                    .doc(memberId)
                    .delete();

                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('تم إزالة العضو بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      String memberId, Map<String, dynamic> memberData, AppLocalizations l10n) {
    final business = ref.read(currentBusinessProvider).valueOrNull;
    final nameController =
        TextEditingController(text: memberData['name'] ?? '');
    String selectedRole = memberData['role'] ?? 'cashier';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.get('edit')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.get('name'),
                  prefixIcon: Icon(LucideIcons.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: l10n.get('member_role'),
                  prefixIcon: Icon(LucideIcons.shield),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'manager',
                    child: Text(l10n.get('role_manager')),
                  ),
                  DropdownMenuItem(
                    value: 'cashier',
                    child: Text(l10n.get('role_cashier')),
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedRole = value ?? 'cashier');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseFirestore.instance
                      .collection('businesses')
                      .doc(business?.id)
                      .collection('team_members')
                      .doc(memberId)
                      .update({
                    'name': nameController.text.trim(),
                    'role': selectedRole,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('تم تحديث العضو بنجاح'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(l10n.get('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    final l10n = AppLocalizations.of(context);
    final business = ref.read(currentBusinessProvider).valueOrNull;
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'cashier';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.get('invite_member')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.get('name'),
                  prefixIcon: Icon(LucideIcons.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: l10n.get('phone_number'),
                  prefixIcon: Icon(LucideIcons.phone),
                  hintText: '+966XXXXXXXXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: l10n.get('member_role'),
                  prefixIcon: Icon(LucideIcons.shield),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'manager',
                    child: Text(l10n.get('role_manager')),
                  ),
                  DropdownMenuItem(
                    value: 'cashier',
                    child: Text(l10n.get('role_cashier')),
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedRole = value ?? 'cashier');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.get('cancel')),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final phone = phoneController.text.trim();
                      final name = nameController.text.trim();

                      if (phone.isEmpty) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('الرجاء إدخال رقم الهاتف'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);
                      
                      try {
                        // First check if phone is already a business owner
                        final firestoreService = ref.read(firestoreServiceProvider);
                        final isOwner = await firestoreService.isPhoneBusinessOwner(phone);
                        
                        if (isOwner) {
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('هذا الرقم مسجل كصاحب نشاط تجاري ولا يمكن إضافته كعضو فريق'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                          return;
                        }
                        
                        // Check if already a team member of this business
                        final isExistingMember = await firestoreService.isPhoneTeamMember(business?.id ?? '', phone);
                        
                        if (isExistingMember) {
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('هذا الرقم مضاف بالفعل كعضو في الفريق'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                          return;
                        }

                        Navigator.of(context).pop();

                        // Add team member to Firestore
                        await FirebaseFirestore.instance
                            .collection('businesses')
                            .doc(business?.id)
                            .collection('team_members')
                            .add({
                          'name': name.isNotEmpty ? name : phone,
                          'phone': phone,
                          'role': selectedRole,
                          'status': 'active',
                          'createdAt': FieldValue.serverTimestamp(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة العضو بنجاح!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.get('add_team_member')),
            ),
          ],
        ),
      ),
    );
  }
}
