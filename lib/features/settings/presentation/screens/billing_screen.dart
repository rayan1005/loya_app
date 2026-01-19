import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/subscription/providers/subscription_provider.dart';
import '../../../../core/subscription/models/plan_type.dart';
import '../../../../core/subscription/models/plan_limits.dart';
import '../../../../core/subscription/services/subscription_service.dart';
import '../../../shared/widgets/loya_button.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  PlanType _selectedPlan = PlanType.pro;
  bool _isYearly = false;
  bool _isLoading = false;

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
          l10n.isRtl ? 'الفوترة' : 'Billing',
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

                // Billing toggle (Monthly/Yearly)
                _buildBillingToggle(l10n),
                const SizedBox(height: 24),

                // Plans
                Text(
                  l10n.isRtl ? 'اختر باقتك' : 'Choose Your Plan',
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                if (isMobile)
                  Column(
                    children: [
                      _buildPlanCard(PlanType.pro, l10n),
                      const SizedBox(height: 12),
                      _buildPlanCard(PlanType.business, l10n),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPlanCard(PlanType.pro, l10n)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPlanCard(PlanType.business, l10n)),
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
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final subscription = subscriptionAsync.valueOrNull;
    final plan = subscription?.planType ?? PlanType.free;
    final limits = subscription?.limits ?? PlanLimits.forPlan(PlanType.free);
    
    final usedStamps = subscription?.stampsUsedThisMonth ?? 0;
    final maxStamps = limits.maxStampsPerMonth;
    final stampUsageText = maxStamps >= 999999 
        ? '∞' 
        : '$usedStamps/$maxStamps';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: plan == PlanType.business 
              ? [AppColors.programOrange, AppColors.programOrange.withRed(230)]
              : plan == PlanType.pro
                  ? [AppColors.programPurple, AppColors.programPurple.withBlue(230)]
                  : [AppColors.primary, AppColors.primary.withBlue(230)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  plan == PlanType.free 
                      ? LucideIcons.gift
                      : LucideIcons.crown,
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
                      l10n.isRtl ? 'الباقة الحالية' : 'Current Plan',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      l10n.isRtl ? plan.displayNameAr : plan.displayName,
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
                    stampUsageText,
                    style: AppTypography.numberMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    l10n.isRtl ? 'ختم/الشهر' : 'stamps/mo',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (plan == PlanType.free) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text(l10n.isRtl ? 'ترقية الباقة' : 'Upgrade Plan'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillingToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  boxShadow: !_isYearly ? AppColors.softShadow : null,
                ),
                child: Center(
                  child: Text(
                    l10n.isRtl ? 'شهري' : 'Monthly',
                    style: AppTypography.button.copyWith(
                      color: !_isYearly ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  boxShadow: _isYearly ? AppColors.softShadow : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.isRtl ? 'سنوي' : 'Yearly',
                        style: AppTypography.button.copyWith(
                          color: _isYearly ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.isRtl ? 'وفر 20%' : 'Save 20%',
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanType planType, AppLocalizations l10n) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final currentPlan = subscriptionAsync.valueOrNull?.planType ?? PlanType.free;
    
    final isSelected = _selectedPlan == planType;
    final isCurrent = currentPlan == planType;
    final isPopular = planType == PlanType.pro;
    final limits = PlanLimits.forPlan(planType);

    String name = l10n.isRtl ? planType.displayNameAr : planType.displayName;
    String price;
    String period;
    String? originalPrice;
    
    if (_isYearly) {
      if (planType == PlanType.pro) {
        price = '\$189.99';
        originalPrice = '\$239.88';
        period = l10n.isRtl ? '/سنة' : '/year';
      } else {
        price = '\$389.99';
        originalPrice = '\$479.88';
        period = l10n.isRtl ? '/سنة' : '/year';
      }
    } else {
      if (planType == PlanType.pro) {
        price = '\$19.99';
        period = l10n.isRtl ? '/شهر' : '/month';
      } else {
        price = '\$39.99';
        period = l10n.isRtl ? '/شهر' : '/month';
      }
    }

    List<String> features;
    if (planType == PlanType.pro) {
      features = l10n.isRtl ? [
        '${limits.maxCustomers} عميل',
        '${PlanLimits.formatLimit(limits.maxStampsPerMonth)} ختم/شهر',
        '${limits.maxPrograms} برامج',
        '${limits.maxLocations} فروع',
        '${limits.maxTeamMembers} أعضاء فريق',
        'تحليلات متقدمة',
        'دعم بالأولوية',
      ] : [
        '${limits.maxCustomers} customers',
        '${PlanLimits.formatLimit(limits.maxStampsPerMonth)} stamps/month',
        '${limits.maxPrograms} programs',
        '${limits.maxLocations} locations',
        '${limits.maxTeamMembers} team members',
        'Advanced analytics',
        'Priority support',
      ];
    } else {
      features = l10n.isRtl ? [
        'عملاء غير محدودين',
        'أختام غير محدودة',
        'برامج غير محدودة',
        'فروع غير محدودة',
        '${limits.maxTeamMembers} أعضاء فريق',
        'وصول API',
        'Webhooks',
        'دعم مخصص',
      ] : [
        'Unlimited customers',
        'Unlimited stamps',
        'Unlimited programs',
        'Unlimited locations',
        '${limits.maxTeamMembers} team members',
        'API access',
        'Webhooks',
        'Dedicated support',
      ];
    }

    Color accentColor = planType == PlanType.pro 
        ? AppColors.programPurple 
        : AppColors.programOrange;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = planType),
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
                      l10n.isRtl ? 'الأكثر شعبية' : 'Most Popular',
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
                const SizedBox(width: 4),
                Text(
                  period,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (originalPrice != null) ...[
              const SizedBox(height: 4),
              Text(
                originalPrice,
                style: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            
            // Free trial badge
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.isRtl ? '7 أيام تجربة مجانية' : '7-day free trial',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                          l10n.isRtl ? 'الباقة الحالية' : 'Current Plan',
                          style: AppTypography.button.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : LoyaButton(
                      label: l10n.isRtl ? 'اشترك الآن' : 'Subscribe Now',
                      onPressed: _isLoading ? null : () => _handleSubscribe(planType),
                      isOutlined: !isPopular,
                      isLoading: _isLoading && _selectedPlan == planType,
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
              l10n.isRtl ? 'الأسئلة الشائعة' : 'FAQ',
              style: AppTypography.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          _FAQItem(
            question: l10n.isRtl 
                ? 'هل يمكنني تغيير باقتي لاحقاً؟' 
                : 'Can I change my plan later?',
            answer: l10n.isRtl
                ? 'نعم، يمكنك الترقية أو تخفيض باقتك في أي وقت. سيتم احتساب الفرق تلقائياً.'
                : 'Yes, you can upgrade or downgrade your plan at any time. The difference will be calculated automatically.',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _FAQItem(
            question: l10n.isRtl 
                ? 'ما هي طرق الدفع المتاحة؟' 
                : 'What payment methods are available?',
            answer: l10n.isRtl
                ? 'نستخدم Apple Pay للدفع الآمن. جميع المعاملات مشفرة ومحمية.'
                : 'We use Apple Pay for secure payments. All transactions are encrypted and protected.',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _FAQItem(
            question: l10n.isRtl 
                ? 'هل يمكنني إلغاء اشتراكي؟' 
                : 'Can I cancel my subscription?',
            answer: l10n.isRtl
                ? 'نعم، يمكنك إلغاء اشتراكك في أي وقت من إعدادات حسابك في App Store. ستستمر في الوصول حتى نهاية فترة الفوترة.'
                : 'Yes, you can cancel your subscription at any time from your App Store account settings. You\'ll continue to have access until the end of your billing period.',
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(PlanType planType) async {
    setState(() => _isLoading = true);
    
    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final productId = _isYearly 
          ? planType.yearlyProductId 
          : planType.monthlyProductId;
      
      if (productId == null) {
        throw Exception('Invalid product');
      }
      
      final success = await subscriptionService.purchaseSubscription(productId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.isRtl 
                ? 'تم الاشتراك بنجاح!' 
                : 'Subscription successful!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.isRtl 
                ? 'فشل الاشتراك. حاول مرة أخرى.' 
                : 'Subscription failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
