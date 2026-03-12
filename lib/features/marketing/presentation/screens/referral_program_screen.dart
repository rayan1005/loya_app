import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class ReferralProgramScreen extends ConsumerStatefulWidget {
  const ReferralProgramScreen({super.key});

  @override
  ConsumerState<ReferralProgramScreen> createState() => _ReferralProgramScreenState();
}

class _ReferralProgramScreenState extends ConsumerState<ReferralProgramScreen> {
  bool _isEnabled = false;
  int _referrerBonus = 1;
  int _refereeBonus = 1;
  bool _isLoading = true;
  bool _isSaving = false;
  int _totalReferrals = 0;
  int _totalStampsGiven = 0;

  @override
  void initState() {
    super.initState();
    _loadReferralConfig();
  }

  Future<void> _loadReferralConfig() async {
    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .collection('referral_config')
          .doc('settings')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _isEnabled = data['isEnabled'] ?? false;
          _referrerBonus = data['referrerBonus'] ?? 1;
          _refereeBonus = data['refereeBonus'] ?? 1;
          _totalReferrals = data['totalReferrals'] ?? 0;
          _totalStampsGiven = data['totalStampsGiven'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading referral config: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReferralConfig() async {
    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .collection('referral_config')
          .doc('settings')
          .set({
        'isEnabled': _isEnabled,
        'referrerBonus': _referrerBonus,
        'refereeBonus': _refereeBonus,
        'totalReferrals': _totalReferrals,
        'totalStampsGiven': _totalStampsGiven,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الإعدادات ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final userPhone = ref.watch(currentUserPhoneProvider);
    final currentPlan = business?.plan ?? 'free';
    
    // Referral program requires Growth plan (admin phones get full access)
    final hasAccess = AppConfig.businessHasFeature(currentPlan, userPhone, PlanFeature.referralProgram);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSaving
              ? const Center(child: CircularProgressIndicator())
              : hasAccess
              ? _buildContent(l10n, business?.id ?? '')
              : Center(
              child: UpgradePrompt(
                feature: PlanFeature.referralProgram,
                currentPlan: currentPlan,
                isFullScreen: true,
              ),
            ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, String businessId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(LucideIcons.gift, size: 28, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.get('referral_program'), style: AppTypography.headline),
                    const SizedBox(height: 4),
                    Text(
                      l10n.get('referral_program_desc'),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Enable toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isEnabled
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isEnabled ? LucideIcons.checkCircle : LucideIcons.circle,
                    color: _isEnabled ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('referral_program'),
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _isEnabled ? 'Active' : 'Disabled',
                        style: AppTypography.caption.copyWith(
                          color: _isEnabled ? AppColors.success : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() => _isEnabled = value);
                    _saveReferralConfig();
                  },
                  activeColor: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reward Settings
          if (_isEnabled) ...[
            Text(
              l10n.get('referral_reward'),
              style: AppTypography.title,
            ),
            const SizedBox(height: 16),

            // Referrer bonus
            _buildBonusCard(
              icon: LucideIcons.userCheck,
              title: l10n.get('referrer_bonus'),
              subtitle: 'Stamps given to the customer who refers',
              value: _referrerBonus,
              onChanged: (v) {
                setState(() => _referrerBonus = v);
                _saveReferralConfig();
              },
            ),
            const SizedBox(height: 16),

            // Referee bonus
            _buildBonusCard(
              icon: LucideIcons.userPlus,
              title: l10n.get('referee_bonus'),
              subtitle: 'Stamps given to the new customer',
              value: _refereeBonus,
              onChanged: (v) {
                setState(() => _refereeBonus = v);
                _saveReferralConfig();
              },
            ),
            const SizedBox(height: 32),

            // Referral Link
            Text(
              l10n.get('referral_link'),
              style: AppTypography.title,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://loya.live/r/$businessId',
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: 'https://loya.live/r/$businessId'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.get('copied_to_clipboard')),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: Icon(LucideIcons.copy, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats
            Text(
              l10n.get('total_referrals'),
              style: AppTypography.title,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: LucideIcons.users,
                    value: '$_totalReferrals',
                    label: 'Total Referrals',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: LucideIcons.stamp,
                    value: '$_totalStampsGiven',
                    label: 'Stamps Given',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBonusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: Icon(
                  LucideIcons.minus,
                  color: value > 1 ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: AppTypography.title.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < 5 ? () => onChanged(value + 1) : null,
                icon: Icon(
                  LucideIcons.plus,
                  color: value < 5 ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
