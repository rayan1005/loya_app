import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/config/app_config.dart';
import '../../../shared/widgets/loya_button.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String _selectedPlan = 'starter';

  @override
  Widget build(BuildContext context) {
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
          l10n.get('billing'),
          style: AppTypography.headline,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current plan banner
                _buildCurrentPlanBanner(l10n),
                const SizedBox(height: 32),

                // Plans
                Text(
                  l10n.get('choose_plan'),
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                if (isMobile)
                  Column(
                    children: [
                      _buildPlanCard('starter', l10n),
                      const SizedBox(height: 12),
                      _buildPlanCard('growth', l10n),
                      const SizedBox(height: 12),
                      _buildPlanCard('advanced', l10n),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPlanCard('starter', l10n)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPlanCard('growth', l10n)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPlanCard('advanced', l10n)),
                    ],
                  ),

                const SizedBox(height: 32),

                // FAQ
                _buildFAQ(l10n),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue(230),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('current_plan'),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  l10n.get('free_plan'),
                  style: AppTypography.headline.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '1/1',
                style: AppTypography.numberMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                l10n.get('programs'),
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String plan, AppLocalizations l10n) {
    final isSelected = _selectedPlan == plan;
    final isCurrent = plan == 'free'; // TODO: Get from user's actual plan
    final isPopular = plan == 'growth';

    String name;
    String price;
    String period;
    List<String> features;
    Color accentColor;

    switch (plan) {
      case 'starter':
        name = l10n.get('starter_plan');
        price = '€${AppConfig.starterPlanPrice}';
        period = '/${l10n.get('month')}';
        features = [
          l10n.get('feature_1_program'),
          l10n.get('feature_500_passes'),
          l10n.get('feature_basic_analytics'),
          l10n.get('feature_1_branch'),
          l10n.get('feature_email_support'),
        ];
        accentColor = AppColors.textSecondary;
        break;
      case 'growth':
        name = l10n.get('growth_plan');
        price = '€${AppConfig.growthPlanPrice}';
        period = '/${l10n.get('month')}';
        features = [
          l10n.get('feature_3_programs'),
          l10n.get('feature_2500_passes'),
          l10n.get('feature_advanced_analytics'),
          l10n.get('feature_3_branches'),
          l10n.get('feature_2_team_members'),
          l10n.get('feature_referral_program'),
          l10n.get('feature_automations'),
          l10n.get('feature_priority_support'),
        ];
        accentColor = AppColors.programPurple;
        break;
      case 'advanced':
      default:
        name = l10n.get('advanced_plan');
        price = '€${AppConfig.advancedPlanPrice}';
        period = '/${l10n.get('month')}';
        features = [
          l10n.get('feature_unlimited_programs'),
          l10n.get('feature_unlimited_passes'),
          l10n.get('feature_full_analytics'),
          l10n.get('feature_unlimited_branches'),
          l10n.get('feature_10_team_members'),
          l10n.get('feature_api_access'),
          l10n.get('feature_webhooks'),
          l10n.get('feature_dedicated_support'),
        ];
        accentColor = AppColors.programOrange;
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.get('popular'),
                      style: AppTypography.captionSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (period.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    '${l10n.get('currency')}$period',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Features
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.check,
                        size: 18,
                        color: accentColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),

            // Button
            SizedBox(
              width: double.infinity,
              child: isCurrent
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          l10n.get('current_plan'),
                          style: AppTypography.button.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : LoyaButton(
                      label: l10n.get('upgrade'),
                      onPressed: () => _showUpgradeDialog(plan, l10n),
                      isOutlined: !isPopular,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(AppLocalizations l10n) {
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
              l10n.get('faq'),
              style: AppTypography.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          _FAQItem(
            question: l10n.get('faq_q1'),
            answer: l10n.get('faq_a1'),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _FAQItem(
            question: l10n.get('faq_q2'),
            answer: l10n.get('faq_a2'),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _FAQItem(
            question: l10n.get('faq_q3'),
            answer: l10n.get('faq_a3'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(String plan, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(l10n.get('upgrade_plan')),
        content: Text(l10n.get('upgrade_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Integrate Tap Payments
            },
            child: Text(l10n.get('continue')),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.answer,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
