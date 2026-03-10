import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/subscription/providers/subscription_provider.dart';
import '../../../../core/subscription/services/subscription_service.dart';
import '../../../../core/widgets/upgrade_dialog.dart';
import '../../../shared/widgets/loya_button.dart';

/// Customer Info & Action Screen
/// This is the KEY DECISION PAGE after scanning a customer's QR code.
///
/// Flow: SCAN → IDENTIFY CUSTOMER → SHOW DATA → ENABLE VALID ACTIONS → CONFIRM → DONE
///
/// Shows:
/// - Stamp progress (visual)
/// - Customer identity (name, phone)
/// - Custom fields (program-specific personalization)
///
/// Actions:
/// - Add Stamp (always enabled unless program limit reached)
/// - Redeem Reward (disabled if no rewards available)
class CustomerActionScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String? programId;

  const CustomerActionScreen({
    super.key,
    required this.customerId,
    this.programId,
  });

  @override
  ConsumerState<CustomerActionScreen> createState() =>
      _CustomerActionScreenState();
}

class _CustomerActionScreenState extends ConsumerState<CustomerActionScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  // Customer data
  Map<String, dynamic>? _customerData;
  LoyaltyProgram? _program;
  CustomerProgress? _progress;
  int _availableRewards = 0;

  // Success states
  bool _stampSuccess = false;
  bool _redeemSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final businessId = ref.read(currentBusinessIdProvider);
      if (businessId == null) {
        setState(() {
          _error = 'Business not found';
          _isLoading = false;
        });
        return;
      }

      // Fetch customer - customerId could be Auth UID or Firestore doc ID
      var customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .get();

      // Check if this doc belongs to THIS business
      bool resolved = customerDoc.exists &&
          (customerDoc.data()?['businessId'] as String?) == businessId;

      // Fallback 1: Search by firebaseUid for THIS business
      if (!resolved) {
        final byUidQuery = await FirebaseFirestore.instance
            .collection('customers')
            .where('firebaseUid', isEqualTo: widget.customerId)
            .where('businessId', isEqualTo: businessId)
            .limit(1)
            .get();
        if (byUidQuery.docs.isNotEmpty) {
          customerDoc = byUidQuery.docs.first;
          resolved = true;
        }
      }

      // Fallback 2: Search via wallet_passes → phone → customer
      if (!resolved) {
        // Find wallet_pass by user_id to get phone
        final wpQuery = await FirebaseFirestore.instance
            .collection('wallet_passes')
            .where('user_id', isEqualTo: widget.customerId)
            .limit(1)
            .get();
        String? wpPhone;
        if (wpQuery.docs.isNotEmpty) {
          wpPhone = (wpQuery.docs.first.data())['phone'] as String?;
        }
        if (wpPhone != null) {
          final phoneDigits = wpPhone.replaceAll(RegExp(r'\D'), '');
          final last9 = phoneDigits.length >= 9 ? phoneDigits.substring(phoneDigits.length - 9) : phoneDigits;
          for (final variant in [wpPhone, '+966$last9', '0$last9', last9]) {
            final phoneQuery = await FirebaseFirestore.instance
                .collection('customers')
                .where('businessId', isEqualTo: businessId)
                .where('phone', isEqualTo: variant)
                .limit(1)
                .get();
            if (phoneQuery.docs.isNotEmpty) {
              customerDoc = phoneQuery.docs.first;
              resolved = true;
              break;
            }
          }
        }
      }

      // Fallback 3: Call backend resolveCustomer (uses admin.auth to get phone)
      if (!resolved) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          final idToken = await user?.getIdToken();
          if (idToken != null) {
            final response = await http.post(
              Uri.parse('https://api-v4xex7aj3a-uc.a.run.app/api/resolveCustomer'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $idToken',
              },
              body: jsonEncode({
                'uid': widget.customerId,
                'businessId': businessId,
              }),
            );
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              if (data['success'] == true && data['customerId'] != null) {
                final resolvedId = data['customerId'] as String;
                final resolvedDoc = await FirebaseFirestore.instance
                    .collection('customers')
                    .doc(resolvedId)
                    .get();
                if (resolvedDoc.exists) {
                  customerDoc = resolvedDoc;
                  resolved = true;
                }
              }
            }
          }
        } catch (e) {
          debugPrint('[CustomerAction] resolveCustomer API error: $e');
        }
      }

      if (!resolved) {
        setState(() {
          _error = 'هذا العميل تابع لنشاط تجاري آخر';
          _isLoading = false;
        });
        return;
      }

      _customerData = customerDoc.data();

      // Determine program ID
      String? programId = widget.programId;

      // If no program specified, get the active program for this business
      if (programId == null) {
        final programsQuery = await FirebaseFirestore.instance
            .collection('programs')
            .where('businessId', isEqualTo: businessId)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

        if (programsQuery.docs.isNotEmpty) {
          programId = programsQuery.docs.first.id;
        }
      }

      // Fetch program
      if (programId != null) {
        final programDoc = await FirebaseFirestore.instance
            .collection('programs')
            .doc(programId)
            .get();

        if (programDoc.exists) {
          _program = LoyaltyProgram.fromFirestore(programDoc);
        }
      }

      // Fetch customer progress - use resolved doc ID (may differ from widget.customerId)
      final resolvedCustomerId = customerDoc.id;
      if (programId != null) {
        var progressQuery = await FirebaseFirestore.instance
            .collection('customer_progress')
            .where('customerId', isEqualTo: resolvedCustomerId)
            .where('programId', isEqualTo: programId)
            .limit(1)
            .get();

        // Fallback: try with original customerId (Auth UID) in case progress was stored with it
        if (progressQuery.docs.isEmpty && resolvedCustomerId != widget.customerId) {
          progressQuery = await FirebaseFirestore.instance
              .collection('customer_progress')
              .where('customerId', isEqualTo: widget.customerId)
              .where('programId', isEqualTo: programId)
              .limit(1)
              .get();
        }

        if (progressQuery.docs.isNotEmpty) {
          _progress = CustomerProgress.fromFirestore(progressQuery.docs.first);

          // Calculate available rewards
          if (_program != null && _program!.stampsRequired > 0) {
            _availableRewards = _progress!.stamps ~/ _program!.stampsRequired;
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Error loading customer: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addStamp() async {
    if (_isProcessing || _program == null) return;

    // Check subscription stamp limit
    final subscription = ref.read(subscriptionProvider).value;
    if (subscription != null && !subscription.canAddStamp()) {
      UpgradeDialog.showStampLimit(context, subscription.limits.maxStampsPerMonth);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final businessId = ref.read(currentBusinessIdProvider);
      if (businessId == null) return;

      final currentStamps = _progress?.stamps ?? 0;
      final newStamps = currentStamps + 1;

      // Check if customer earned a reward
      final earnedReward = _program!.stampsRequired > 0 &&
          newStamps >= _program!.stampsRequired &&
          currentStamps < _program!.stampsRequired;

      // Update or create progress
      if (_progress != null) {
        await FirebaseFirestore.instance
            .collection('customer_progress')
            .doc(_progress!.id)
            .update({
          'stamps': newStamps,
          'lastStampAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('customer_progress').add({
          'customerId': widget.customerId,
          'programId': _program!.id,
          'businessId': businessId,
          'stamps': 1,
          'totalStamps': 1,
          'rewardsEarned': 0,
          'rewardsRedeemed': 0,
          'lastStampAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Log activity
      await FirebaseFirestore.instance.collection('activity').add({
        'businessId': businessId,
        'customerId': widget.customerId,
        'programId': _program!.id,
        'type': 'stamp_added',
        'description':
            earnedReward ? 'Stamp added - Reward earned!' : 'Stamp added',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update customer total visits
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({
        'totalVisits': FieldValue.increment(1),
        'lastVisit': FieldValue.serverTimestamp(),
      });

      // Increment subscription stamp usage
      final subService = ref.read(subscriptionServiceProvider);
      await subService.incrementStampUsage(businessId);

      setState(() {
        _stampSuccess = true;
        _isProcessing = false;
      });

      // Reload data to show updated stamps
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadCustomerData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(earnedReward
                ? 'تم إضافة الختم - مكافأة جديدة! 🎉'
                : 'تم إضافة الختم بنجاح ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _redeemReward() async {
    if (_isProcessing || _availableRewards <= 0) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استبدال المكافأة'),
        content: Text(
          'هل تريد استبدال مكافأة واحدة لهذا العميل؟\n\n'
          'المكافآت المتاحة: $_availableRewards',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('استبدال'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final businessId = ref.read(currentBusinessIdProvider);
      if (businessId == null) return;

      final stampsRequired = _program?.stampsRequired ?? 10;
      final currentStamps = _progress?.stamps ?? 0;
      final newStamps = currentStamps - stampsRequired;

      // Update progress - deduct stamps
      if (_progress != null) {
        await FirebaseFirestore.instance
            .collection('customer_progress')
            .doc(_progress!.id)
            .update({
          'stamps': newStamps > 0 ? newStamps : 0,
          'rewardsRedeemed': FieldValue.increment(1),
          'lastRedeemAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Log activity
      await FirebaseFirestore.instance.collection('activity').add({
        'businessId': businessId,
        'customerId': widget.customerId,
        'programId': _program?.id,
        'type': 'reward_redeemed',
        'description': 'Reward redeemed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update customer total rewards
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({
        'totalRewards': FieldValue.increment(1),
        'lastRewardAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _redeemSuccess = true;
        _isProcessing = false;
      });

      // Reload data
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadCustomerData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم استبدال المكافأة بنجاح 🎁'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(LucideIcons.arrowRight, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'معلومات العميل',
          style:
              AppTypography.title.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : _buildContent(isMobile),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LoyaButton(
              label: 'العودة',
              onPressed: () => context.pop(),
              icon: LucideIcons.arrowRight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // Customer Card
              _buildCustomerCard(),

              const SizedBox(height: 24),

              // Stamp Progress
              _buildStampProgress(),

              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 24),

              // Quick action to scan another customer
              _buildScanAnotherButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    final customerName = _customerData?['name'] as String? ??
        _customerData?['displayName'] as String?;
    final customerPhone = _customerData?['phone'] as String? ?? '';
    final totalVisits = _customerData?['totalVisits'] as int? ?? 0;
    final totalRewards = _customerData?['totalRewards'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                customerName?.isNotEmpty == true
                    ? customerName![0].toUpperCase()
                    : '👤',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            customerName ?? 'عميل',
            style: AppTypography.headline.copyWith(
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 4),

          // Phone
          if (customerPhone.isNotEmpty)
            Text(
              customerPhone,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatBadge(
                icon: LucideIcons.calendarCheck,
                label: 'زيارات',
                value: totalVisits.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatBadge(
                icon: LucideIcons.gift,
                label: 'مكافآت',
                value: totalRewards.toString(),
              ),
            ],
          ),

          // Program name
          if (_program != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.tag, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _program!.name,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStampProgress() {
    final currentStamps = _progress?.stamps ?? 0;
    final stampsRequired = _program?.stampsRequired ?? 10;
    final progressPercent = (currentStamps / stampsRequired).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأختام',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _availableRewards > 0
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.gift,
                      size: 14,
                      color: _availableRewards > 0
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_availableRewards مكافأة',
                      style: AppTypography.caption.copyWith(
                        color: _availableRewards > 0
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stamp counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$currentStamps',
                style: AppTypography.headline.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' / $stampsRequired',
                style: AppTypography.headline.copyWith(
                  fontSize: 24,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 12,
              backgroundColor: AppColors.inputBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                _availableRewards > 0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Progress text
          Text(
            _availableRewards > 0
                ? '🎉 مكافأة متاحة للاستبدال!'
                : '${stampsRequired - (currentStamps % stampsRequired)} أختام للمكافأة القادمة',
            style: AppTypography.body.copyWith(
              color: _availableRewards > 0
                  ? AppColors.success
                  : AppColors.textSecondary,
              fontWeight:
                  _availableRewards > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // ADD STAMP Button
        _ActionButton(
          icon: LucideIcons.plus,
          label: 'إضافة ختم',
          subtitle: 'Add Stamp',
          color: AppColors.primary,
          isLoading: _isProcessing && !_redeemSuccess,
          onPressed: _addStamp,
        ),

        const SizedBox(height: 12),

        // REDEEM REWARD Button
        _ActionButton(
          icon: LucideIcons.gift,
          label: 'استبدال مكافأة',
          subtitle: _availableRewards > 0
              ? 'Redeem Reward • $_availableRewards available'
              : 'No rewards available for this customer',
          color: AppColors.success,
          enabled: _availableRewards > 0,
          isLoading: _isProcessing && _redeemSuccess,
          onPressed: _redeemReward,
        ),
      ],
    );
  }

  Widget _buildScanAnotherButton() {
    return TextButton.icon(
      onPressed: () {
        // Go back to stamper screen to scan another customer
        context.go('/stamper');
      },
      icon: const Icon(LucideIcons.scanLine),
      label: const Text('مسح عميل آخر'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
      ),
    );
  }
}

/// Styled action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    this.enabled = true,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppColors.disabled;
    final textColor = enabled ? Colors.white : AppColors.textDisabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && !isLoading ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(textColor),
                          ),
                        )
                      : Icon(icon, color: textColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.titleMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronLeft,
                  color: textColor.withOpacity(0.7),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
