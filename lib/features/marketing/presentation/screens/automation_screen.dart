import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../shared/widgets/upgrade_prompt.dart';

class AutomationScreen extends ConsumerStatefulWidget {
  const AutomationScreen({super.key});

  @override
  ConsumerState<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends ConsumerState<AutomationScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final businessId = ref.watch(currentBusinessIdProvider);
    final userPhone = ref.watch(currentUserPhoneProvider);
    final currentPlan = business?.plan ?? 'free';

    // Automation requires Growth plan (admin phones get full access)
    final hasAccess = AppConfig.businessHasFeature(
        currentPlan, userPhone, PlanFeature.automatedPush);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: hasAccess
          ? _buildContent(l10n, businessId)
          : Center(
              child: UpgradePrompt(
                feature: PlanFeature.automatedPush,
                currentPlan: currentPlan,
                isFullScreen: true,
              ),
            ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, String? businessId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rules list section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.list,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.get('automation_rules'),
                          style: AppTypography.title,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stream rules from Firestore
                    if (businessId != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('businesses')
                            .doc(businessId)
                            .collection('automationRules')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final rules = snapshot.data?.docs ?? [];

                          if (rules.isEmpty) {
                            return _buildEmptyState(l10n);
                          }

                          return Column(
                            children: rules.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final rule =
                                  AutomationRule.fromFirestore(doc.id, data);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildRuleCard(rule, l10n, businessId),
                              );
                            }).toList(),
                          );
                        },
                      )
                    else
                      _buildEmptyState(l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.zap,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('no_automation_rules'),
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('automation_desc'),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _showAddRuleDialog,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(l10n.get('add_rule')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(
      AutomationRule rule, AppLocalizations l10n, String businessId) {
    final triggerInfo = _getTriggerInfo(rule.trigger, l10n);
    final actionInfo = _getActionInfo(rule.action, l10n);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rule.isEnabled
            ? AppColors.primary.withOpacity(0.02)
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: rule.isEnabled
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: rule.isEnabled
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  triggerInfo.icon,
                  color: rule.isEnabled
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            triggerInfo.label,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            LucideIcons.arrowRight,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            actionInfo.label,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Custom iOS-style toggle (blue when active)
              _buildCustomToggle(
                value: rule.isEnabled,
                onChanged: (value) => _toggleRule(businessId, rule.id, value),
              ),
            ],
          ),

          // Message preview
          if (rule.message.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.messageCircle,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule.message,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditRuleDialog(rule, businessId),
                icon: Icon(LucideIcons.pencil,
                    size: 16, color: AppColors.primary),
                label: Text(l10n.get('edit'),
                    style: TextStyle(color: AppColors.primary)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteRule(businessId, rule.id, l10n),
                icon:
                    Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                label: Text(l10n.get('delete'),
                    style: TextStyle(color: AppColors.error)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomToggle(
      {required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      behavior: HitTestBehavior
          .opaque, // Ensure tap is detected even on transparent areas
      onTap: () {
        debugPrint(
            '[AutomationToggle] Toggle tapped, current value: $value, new value: ${!value}');
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.all(4), // Add extra hit area
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 51,
          height: 31,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.5),
            color: value ? AppColors.primary : const Color(0xFFE5E5EA),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleRule(String businessId, String ruleId, bool value) async {
    debugPrint('[AutomationToggle] Updating rule $ruleId to isEnabled=$value');
    try {
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .collection('automationRules')
          .doc(ruleId)
          .update({'isEnabled': value});
      debugPrint('[AutomationToggle] Successfully updated rule $ruleId');
    } catch (e) {
      debugPrint('[AutomationToggle] Error updating rule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحديث القاعدة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteRule(
      String businessId, String ruleId, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('delete_rule')),
        content: Text(l10n.get('delete_rule_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('businesses')
            .doc(businessId)
            .collection('automationRules')
            .doc(ruleId)
            .delete();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting rule: $e')),
          );
        }
      }
    }
  }

  TriggerInfo _getTriggerInfo(String trigger, AppLocalizations l10n) {
    switch (trigger) {
      case 'birthday':
        return TriggerInfo(
          icon: LucideIcons.cake,
          label: l10n.get('trigger_birthday'),
        );
      case 'inactive_7':
        return TriggerInfo(
          icon: LucideIcons.userX,
          label:
              '${l10n.get('trigger_inactive')} (7 ${l10n.get('inactive_days')})',
        );
      case 'reward_expiring':
        return TriggerInfo(
          icon: LucideIcons.clock,
          label: l10n.get('trigger_reward_expiring'),
        );
      case 'first_visit':
        return TriggerInfo(
          icon: LucideIcons.sparkles,
          label: l10n.get('trigger_first_visit'),
        );
      default:
        return TriggerInfo(
          icon: LucideIcons.zap,
          label: trigger,
        );
    }
  }

  ActionInfo _getActionInfo(String action, AppLocalizations l10n) {
    switch (action) {
      case 'push':
        return ActionInfo(
          icon: LucideIcons.bell,
          label: l10n.get('action_send_push'),
        );
      case 'sms':
        return ActionInfo(
          icon: LucideIcons.messageSquare,
          label: l10n.get('action_send_sms'),
        );
      case 'email':
        return ActionInfo(
          icon: LucideIcons.mail,
          label: l10n.get('action_send_email'),
        );
      case 'stamps':
        return ActionInfo(
          icon: LucideIcons.stamp,
          label: l10n.get('action_add_stamps'),
        );
      default:
        return ActionInfo(
          icon: LucideIcons.send,
          label: action,
        );
    }
  }

  void _showAddRuleDialog() {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) return;

    String selectedTrigger = 'birthday';
    String selectedAction = 'push';
    final nameController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(LucideIcons.plus, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(l10n.get('add_rule')),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.get('rule_name'),
                      hintText: l10n.get('rule_name_hint'),
                      prefixIcon: Icon(LucideIcons.tag),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTrigger,
                    decoration: InputDecoration(
                      labelText: l10n.get('trigger'),
                      prefixIcon: Icon(LucideIcons.zap),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'birthday',
                        child: Text(l10n.get('trigger_birthday')),
                      ),
                      DropdownMenuItem(
                        value: 'inactive_7',
                        child: Text(l10n.get('trigger_inactive')),
                      ),
                      DropdownMenuItem(
                        value: 'reward_expiring',
                        child: Text(l10n.get('trigger_reward_expiring')),
                      ),
                      DropdownMenuItem(
                        value: 'first_visit',
                        child: Text(l10n.get('trigger_first_visit')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedTrigger = value ?? 'birthday');
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedAction,
                    decoration: InputDecoration(
                      labelText: l10n.get('action'),
                      prefixIcon: Icon(LucideIcons.send),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'push',
                        child: Text(l10n.get('action_send_push')),
                      ),
                      DropdownMenuItem(
                        value: 'stamps',
                        child: Text(l10n.get('action_add_stamps')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedAction = value ?? 'push');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.get('message'),
                      hintText: l10n.get('message_hint'),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Icon(LucideIcons.messageCircle),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('businesses')
                        .doc(businessId)
                        .collection('automationRules')
                        .add({
                      'name': nameController.text,
                      'trigger': selectedTrigger,
                      'action': selectedAction,
                      'message': messageController.text,
                      'isEnabled': true,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding rule: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.get('add_rule')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRuleDialog(AutomationRule rule, String businessId) {
    final l10n = AppLocalizations.of(context);

    String selectedTrigger = rule.trigger;
    String selectedAction = rule.action;
    final nameController = TextEditingController(text: rule.name);
    final messageController = TextEditingController(text: rule.message);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(LucideIcons.pencil, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(l10n.get('edit_rule')),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.get('rule_name'),
                      prefixIcon: Icon(LucideIcons.tag),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTrigger,
                    decoration: InputDecoration(
                      labelText: l10n.get('trigger'),
                      prefixIcon: Icon(LucideIcons.zap),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'birthday',
                        child: Text(l10n.get('trigger_birthday')),
                      ),
                      DropdownMenuItem(
                        value: 'inactive_7',
                        child: Text(l10n.get('trigger_inactive')),
                      ),
                      DropdownMenuItem(
                        value: 'reward_expiring',
                        child: Text(l10n.get('trigger_reward_expiring')),
                      ),
                      DropdownMenuItem(
                        value: 'first_visit',
                        child: Text(l10n.get('trigger_first_visit')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedTrigger = value ?? 'birthday');
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedAction,
                    decoration: InputDecoration(
                      labelText: l10n.get('action'),
                      prefixIcon: Icon(LucideIcons.send),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'push',
                        child: Text(l10n.get('action_send_push')),
                      ),
                      DropdownMenuItem(
                        value: 'stamps',
                        child: Text(l10n.get('action_add_stamps')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedAction = value ?? 'push');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.get('message'),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Icon(LucideIcons.messageCircle),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('businesses')
                        .doc(businessId)
                        .collection('automationRules')
                        .doc(rule.id)
                        .update({
                      'name': nameController.text,
                      'trigger': selectedTrigger,
                      'action': selectedAction,
                      'message': messageController.text,
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating rule: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.get('save')),
            ),
          ],
        ),
      ),
    );
  }
}

class AutomationRule {
  final String id;
  final String name;
  final String trigger;
  final String action;
  final String message;
  final bool isEnabled;

  AutomationRule({
    required this.id,
    required this.name,
    required this.trigger,
    required this.action,
    required this.message,
    required this.isEnabled,
  });

  factory AutomationRule.fromFirestore(String id, Map<String, dynamic> data) {
    return AutomationRule(
      id: id,
      name: data['name'] ?? '',
      trigger: data['trigger'] ?? 'birthday',
      action: data['action'] ?? 'push',
      message: data['message'] ?? '',
      isEnabled: data['isEnabled'] ?? false,
    );
  }

  AutomationRule copyWith({
    String? id,
    String? name,
    String? trigger,
    String? action,
    String? message,
    bool? isEnabled,
  }) {
    return AutomationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      trigger: trigger ?? this.trigger,
      action: action ?? this.action,
      message: message ?? this.message,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class TriggerInfo {
  final IconData icon;
  final String label;

  TriggerInfo({required this.icon, required this.label});
}

class ActionInfo {
  final IconData icon;
  final String label;

  ActionInfo({required this.icon, required this.label});
}
