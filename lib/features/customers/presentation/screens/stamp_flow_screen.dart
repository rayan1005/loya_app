import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../shared/widgets/loya_button.dart';

/// Customer data for stamp flow (local UI model)
class _CustomerStampData {
  final String id;
  final String phone;
  final String? name;
  final int stamps;
  final int maxStamps;
  final String? programId;
  final String? passId;

  _CustomerStampData({
    required this.id,
    required this.phone,
    this.name,
    required this.stamps,
    required this.maxStamps,
    this.programId,
    this.passId,
  });
}

/// The stamp flow screen - the critical business UX flow:
/// 1. Business enters customer phone number
/// 2. System finds or creates customer
/// 3. Shows customer card
/// 4. Business taps 'Add Stamp'
/// 5. Immediate visual confirmation
class StampFlowScreen extends ConsumerStatefulWidget {
  const StampFlowScreen({super.key});

  @override
  ConsumerState<StampFlowScreen> createState() => _StampFlowScreenState();
}

class _StampFlowScreenState extends ConsumerState<StampFlowScreen> {
  final _phoneController = TextEditingController();
  String _fullPhoneNumber = '';
  bool _isSearching = false;
  _CustomerStampData? _foundCustomer;
  bool _isStamping = false;
  bool _stampSuccess = false;
  bool _showRewardUnlocked = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: EdgeInsets.all(
                isMobile
                    ? AppSpacing.pagePaddingMobile
                    : AppSpacing.pagePadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_stampSuccess)
                    _buildSuccessView(l10n)
                  else if (_foundCustomer != null)
                    _buildCustomerView(l10n)
                  else
                    _buildSearchView(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchView(AppLocalizations l10n) {
    return Column(
      children: [
        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            LucideIcons.search,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          l10n.get('find_customer'),
          style: AppTypography.headline.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          l10n.get('enter_phone_to_add_stamp'),
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Phone input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppColors.softShadow,
          ),
          padding: const EdgeInsets.all(20),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: IntlPhoneField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: l10n.get('phone_placeholder'),
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              initialCountryCode: 'SA',
              disableLengthCheck: true,
              showDropdownIcon: true,
              dropdownIconPosition: IconPosition.trailing,
              flagsButtonPadding: const EdgeInsets.only(left: 12),
              onChanged: (phone) {
                _fullPhoneNumber = phone.completeNumber;
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Search button
        LoyaButton(
          label: l10n.get('search'),
          onPressed: _isSearching ? null : _searchCustomer,
          isLoading: _isSearching,
          icon: LucideIcons.search,
        ),
      ],
    );
  }

  Widget _buildCustomerView(AppLocalizations l10n) {
    final customer = _foundCustomer!;

    return Column(
      children: [
        // Customer card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.programOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: customer.name != null && customer.name!.isNotEmpty
                    ? Center(
                        child: Text(
                          customer.name![0].toUpperCase(),
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.programOrange,
                          ),
                        ),
                      )
                    : const Icon(
                        LucideIcons.user,
                        size: 36,
                        color: AppColors.programOrange,
                      ),
              ),
              const SizedBox(height: 16),

              // Name
              if (customer.name != null)
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
              const SizedBox(height: 20),

              // Stamps visual
              _buildStampsGrid(customer),

              const SizedBox(height: 16),

              // Progress text
              Text(
                '${customer.stamps}/${customer.maxStamps} ${l10n.get('stamps')}',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Add stamp button
        LoyaButton(
          label: l10n.get('add_stamp'),
          onPressed: _isStamping ? null : _addStamp,
          isLoading: _isStamping,
          icon: LucideIcons.stamp,
        ),
        const SizedBox(height: 12),

        // Back button
        TextButton(
          onPressed: () {
            setState(() {
              _foundCustomer = null;
              _phoneController.clear();
            });
          },
          child: Text(
            l10n.get('search_another'),
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStampsGrid(_CustomerStampData customer) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(customer.maxStamps, (index) {
        final isFilled = index < customer.stamps;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isFilled ? AppColors.programOrange : AppColors.inputBackground,
            border: Border.all(
              color: isFilled ? AppColors.programOrange : AppColors.border,
              width: 2,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: AppColors.programOrange.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isFilled
              ? const Icon(
                  LucideIcons.check,
                  size: 22,
                  color: Colors.white,
                )
              : null,
        );
      }),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n) {
    return Column(
      children: [
        // Success animation container
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (0.5 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _showRewardUnlocked ? LucideIcons.gift : LucideIcons.check,
              size: 56,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Success message
        Text(
          _showRewardUnlocked
              ? l10n.get('reward_unlocked')
              : l10n.get('stamp_added'),
          style: AppTypography.headline.copyWith(
            color: _showRewardUnlocked
                ? AppColors.programPurple
                : AppColors.success,
          ),
        ),
        const SizedBox(height: 8),

        if (_showRewardUnlocked)
          Text(
            l10n.get('customer_can_redeem'),
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

        const SizedBox(height: 32),

        // Customer info reminder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_foundCustomer?.name != null)
                    Text(
                      _foundCustomer!.name!,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _foundCustomer?.phone ?? '',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Text(
                '${(_foundCustomer?.stamps ?? 0) + 1}/${_foundCustomer?.maxStamps ?? 10}',
                style: AppTypography.numberMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // New stamp button
        LoyaButton(
          label: l10n.get('add_another_stamp'),
          onPressed: _resetFlow,
          icon: LucideIcons.plus,
        ),
      ],
    );
  }

  Future<void> _searchCustomer() async {
    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) return;

    if (_fullPhoneNumber.isEmpty || _fullPhoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال رقم هاتف صحيح'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Search for customer pass
      final passQuery = await FirebaseFirestore.instance
          .collection('wallet_passes')
          .where('businessId', isEqualTo: businessId)
          .where('customerPhone', isEqualTo: _fullPhoneNumber)
          .limit(1)
          .get();

      if (passQuery.docs.isNotEmpty) {
        final passDoc = passQuery.docs.first;
        final passData = passDoc.data();

        setState(() {
          _isSearching = false;
          _foundCustomer = _CustomerStampData(
            id: passData['customerId'] ?? '',
            phone: passData['customerPhone'] ?? _fullPhoneNumber,
            name: passData['customerName'],
            stamps: passData['currentStamps'] ?? 0,
            maxStamps: passData['stampsRequired'] ?? 10,
            programId: passData['programId'],
            passId: passDoc.id,
          );
        });
        return;
      }

      // Check if customer exists in customers collection
      final customerQuery = await FirebaseFirestore.instance
          .collection('customers')
          .where('businessId', isEqualTo: businessId)
          .where('phone', isEqualTo: _fullPhoneNumber)
          .limit(1)
          .get();

      if (customerQuery.docs.isNotEmpty) {
        final customerDoc = customerQuery.docs.first;
        final customerData = customerDoc.data();

        // Get program to get max stamps
        final programQuery = await FirebaseFirestore.instance
            .collection('programs')
            .where('businessId', isEqualTo: businessId)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

        int maxStamps = 10;
        String? programId;
        if (programQuery.docs.isNotEmpty) {
          maxStamps = programQuery.docs.first.data()['stampsRequired'] ?? 10;
          programId = programQuery.docs.first.id;
        }

        setState(() {
          _isSearching = false;
          _foundCustomer = _CustomerStampData(
            id: customerDoc.id,
            phone: customerData['phone'] ?? _fullPhoneNumber,
            name: customerData['name'],
            stamps: 0,
            maxStamps: maxStamps,
            programId: programId,
          );
        });
        return;
      }

      // Customer not found - create new
      final programQuery = await FirebaseFirestore.instance
          .collection('programs')
          .where('businessId', isEqualTo: businessId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      int maxStamps = 10;
      String? programId;
      if (programQuery.docs.isNotEmpty) {
        maxStamps = programQuery.docs.first.data()['stampsRequired'] ?? 10;
        programId = programQuery.docs.first.id;
      }

      // Create new customer
      final newCustomerRef =
          await FirebaseFirestore.instance.collection('customers').add({
        'businessId': businessId,
        'phone': _fullPhoneNumber,
        'name': null,
        'totalVisits': 0,
        'totalRewards': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSearching = false;
        _foundCustomer = _CustomerStampData(
          id: newCustomerRef.id,
          phone: _fullPhoneNumber,
          name: null,
          stamps: 0,
          maxStamps: maxStamps,
          programId: programId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم إضافة عميل جديد'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addStamp() async {
    if (_foundCustomer == null) return;

    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) return;

    setState(() => _isStamping = true);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      final currentStamps = _foundCustomer!.stamps;
      final maxStamps = _foundCustomer!.maxStamps;
      final willUnlockReward = currentStamps + 1 >= maxStamps;

      // Update pass if exists
      if (_foundCustomer!.passId != null) {
        await FirebaseFirestore.instance
            .collection('wallet_passes')
            .doc(_foundCustomer!.passId)
            .update({
          'currentStamps': currentStamps + 1,
          'lastStampAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Update customer visits
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(_foundCustomer!.id)
          .update({
        'totalVisits': FieldValue.increment(1),
        'lastVisit': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log activity
      await FirebaseFirestore.instance.collection('activity_log').add({
        'businessId': businessId,
        'customerId': _foundCustomer!.id,
        'customerPhone': _foundCustomer!.phone,
        'customerName': _foundCustomer!.name,
        'programId': _foundCustomer!.programId,
        'type': 'stamp',
        'details': {'stampsAfter': currentStamps + 1},
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (willUnlockReward) {
        // Log reward
        await FirebaseFirestore.instance.collection('activity_log').add({
          'businessId': businessId,
          'customerId': _foundCustomer!.id,
          'customerPhone': _foundCustomer!.phone,
          'customerName': _foundCustomer!.name,
          'programId': _foundCustomer!.programId,
          'type': 'reward',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update customer rewards
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(_foundCustomer!.id)
            .update({
          'totalRewards': FieldValue.increment(1),
        });
      }

      // Success haptic
      HapticFeedback.heavyImpact();

      setState(() {
        _isStamping = false;
        _stampSuccess = true;
        _showRewardUnlocked = willUnlockReward;
      });
    } catch (e) {
      setState(() => _isStamping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  void _resetFlow() {
    setState(() {
      _foundCustomer = null;
      _stampSuccess = false;
      _showRewardUnlocked = false;
      _phoneController.clear();
      _fullPhoneNumber = '';
    });
  }
}
