import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/data/providers/data_providers.dart';

class SubusersScreen extends ConsumerStatefulWidget {
  const SubusersScreen({super.key});

  @override
  ConsumerState<SubusersScreen> createState() => _SubusersScreenState();
}

class _SubusersScreenState extends ConsumerState<SubusersScreen> {
  @override
  Widget build(BuildContext context) {
    final businessId = ref.watch(currentBusinessIdProvider);

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
                Icon(LucideIcons.users, size: 28, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('المستخدمين الفرعيين', style: AppTypography.headline),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(businessId),
                  icon: const Icon(LucideIcons.userPlus),
                  label: const Text('إضافة مستخدم'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'أضف موظفين للمساعدة في إدارة برامج الولاء',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Roles Legend
            _buildRolesLegend(),
            const SizedBox(height: 24),

            // Users List
            Expanded(
              child: businessId == null
                  ? const Center(child: Text('يرجى تسجيل الدخول'))
                  : _buildUsersList(businessId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _buildRoleChip(
              'ختّام', SubUserRole.stamper, LucideIcons.stamp, Colors.blue),
          const SizedBox(width: 16),
          _buildRoleChip(
              'مدير', SubUserRole.manager, LucideIcons.userCog, Colors.orange),
          const SizedBox(width: 16),
          _buildRoleChip(
              'مسؤول', SubUserRole.admin, LucideIcons.shield, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildRoleChip(
      String label, SubUserRole role, IconData icon, Color color) {
    final permissions = switch (role) {
      SubUserRole.stamper => 'إضافة أختام فقط',
      SubUserRole.manager => 'أختام + إدارة عملاء',
      SubUserRole.admin => 'كل الصلاحيات',
    };

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.label.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(
              permissions,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(String businessId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subusers')
          .where('businessId', isEqualTo: businessId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.userX,
                    size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد مستخدمين فرعيين',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'أضف موظفين للمساعدة في إدارة البرامج',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final user = SubUser.fromFirestore(doc);
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildUserCard(SubUser user) {
    final roleColor = switch (user.role) {
      SubUserRole.stamper => Colors.blue,
      SubUserRole.manager => Colors.orange,
      SubUserRole.admin => Colors.purple,
    };

    final roleLabel = switch (user.role) {
      SubUserRole.stamper => 'ختّام',
      SubUserRole.manager => 'مدير',
      SubUserRole.admin => 'مسؤول',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: AppTypography.title.copyWith(color: roleColor),
              ),
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
                    Text(user.name, style: AppTypography.titleMedium),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleLabel,
                        style: AppTypography.caption.copyWith(color: roleColor),
                      ),
                    ),
                    if (!user.isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'غير نشط',
                          style:
                              AppTypography.caption.copyWith(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (user.lastLoginAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'آخر دخول: ${_formatDate(user.lastLoginAt!)}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical),
            onSelected: (value) => _handleUserAction(value, user),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(LucideIcons.pencil, size: 18),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: user.isActive ? 'disable' : 'enable',
                child: Row(
                  children: [
                    Icon(
                      user.isActive ? LucideIcons.userX : LucideIcons.userCheck,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(user.isActive ? 'تعطيل' : 'تفعيل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleUserAction(String action, SubUser user) async {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'disable':
      case 'enable':
        await FirebaseFirestore.instance
            .collection('subusers')
            .doc(user.id)
            .update({'isActive': action == 'enable'});
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف المستخدم'),
            content: Text('هل أنت متأكد من حذف ${user.name}؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await FirebaseFirestore.instance
              .collection('subusers')
              .doc(user.id)
              .delete();
        }
        break;
    }
  }

  void _showAddUserDialog(String? businessId) {
    if (businessId == null) return;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    SubUserRole selectedRole = SubUserRole.stamper;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.userPlus, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('إضافة مستخدم جديد'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: const Icon(LucideIcons.user),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: const Icon(LucideIcons.mail),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SubUserRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'الصلاحية',
                    prefixIcon: const Icon(LucideIcons.shield),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: SubUserRole.stamper,
                        child: Text('ختّام - إضافة أختام فقط')),
                    DropdownMenuItem(
                        value: SubUserRole.manager,
                        child: Text('مدير - أختام + إدارة عملاء')),
                    DropdownMenuItem(
                        value: SubUserRole.admin,
                        child: Text('مسؤول - كل الصلاحيات')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRole = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  return;
                }

                await FirebaseFirestore.instance.collection('subusers').add({
                  'businessId': businessId,
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': selectedRole.name,
                  'locationIds': [],
                  'programIds': [],
                  'isActive': true,
                  'createdAt': Timestamp.now(),
                });

                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(SubUser user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    SubUserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.userCog, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('تعديل المستخدم'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: const Icon(LucideIcons.user),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: const Icon(LucideIcons.mail),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SubUserRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'الصلاحية',
                    prefixIcon: const Icon(LucideIcons.shield),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: SubUserRole.stamper, child: Text('ختّام')),
                    DropdownMenuItem(
                        value: SubUserRole.manager, child: Text('مدير')),
                    DropdownMenuItem(
                        value: SubUserRole.admin, child: Text('مسؤول')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRole = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('subusers')
                    .doc(user.id)
                    .update({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': selectedRole.name,
                });

                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
