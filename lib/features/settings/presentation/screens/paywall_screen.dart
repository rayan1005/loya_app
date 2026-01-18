import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/subscription/models/models.dart';
import '../../../core/subscription/providers/subscription_provider.dart';
import '../../../core/subscription/services/subscription_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String? highlightedPlan;
  final String? limitReachedMessage;

  const PaywallScreen({
    super.key,
    this.highlightedPlan,
    this.limitReachedMessage,
  });

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isYearly = false;
  bool _isLoading = false;
  PlanType _selectedPlan = PlanType.pro;

  @override
  void initState() {
    super.initState();
    if (widget.highlightedPlan != null) {
      _selectedPlan = PlanType.fromString(widget.highlightedPlan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _restorePurchases,
            child: Text(
              'استعادة المشتريات',
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Limit reached message
              if (widget.limitReachedMessage != null) ...[
                _buildLimitMessage(),
                const SizedBox(height: 24),
              ],

              // Billing toggle
              _buildBillingToggle(),
              const SizedBox(height: 24),

              // Plan cards
              _buildPlanCards(),
              const SizedBox(height: 24),

              // Feature comparison
              _buildFeatureComparison(),
              const SizedBox(height: 32),

              // Subscribe button
              _buildSubscribeButton(),
              const SizedBox(height: 16),

              // Terms
              _buildTerms(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(LucideIcons.crown, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          'اختر باقتك',
          style: AppTypography.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'جميع الباقات تتضمن كل المميزات\nالفرق فقط في الحدود',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLimitMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.limitReachedMessage!,
              style: AppTypography.body.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isYearly ? AppColors.softShadow : null,
                ),
                child: Text(
                  'شهري',
                  style: AppTypography.titleMedium.copyWith(
                    color: !_isYearly ? AppColors.primary : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
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
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isYearly ? AppColors.softShadow : null,
                ),
                child: Column(
                  children: [
                    Text(
                      'سنوي',
                      style: AppTypography.titleMedium.copyWith(
                        color: _isYearly ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'وفر شهرين',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
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
    );
  }

  Widget _buildPlanCards() {
    return Column(
      children: [
        _buildPlanCard(PlanType.pro),
        const SizedBox(height: 12),
        _buildPlanCard(PlanType.business),
      ],
    );
  }

  Widget _buildPlanCard(PlanType plan) {
    final isSelected = _selectedPlan == plan;
    final limits = PlanLimits.forPlan(plan);
    final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final monthlyEquivalent = _isYearly ? (plan.yearlyPrice / 12).toStringAsFixed(0) : null;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Plan name
                Text(
                  plan.displayNameAr,
                  style: AppTypography.title.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),

                const Spacer(),

                // Popular badge for Pro
                if (plan == PlanType.pro)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الأكثر شعبية',
                      style: AppTypography.caption.copyWith(
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
                  '\$${price.toStringAsFixed(0)}',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _isYearly ? '/سنة' : '/شهر',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (monthlyEquivalent != null) ...[
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '(\$$monthlyEquivalent/شهر)',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Key limits
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLimitBadge(
                  '${PlanLimits.formatLimit(limits.maxCustomers)} عميل',
                  LucideIcons.users,
                ),
                _buildLimitBadge(
                  '${PlanLimits.formatLimit(limits.maxStampsPerMonth)} ختم/شهر',
                  LucideIcons.stamp,
                ),
                _buildLimitBadge(
                  '${PlanLimits.formatLimit(limits.maxPrograms)} برنامج',
                  LucideIcons.award,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return ExpansionTile(
      title: Text(
        'مقارنة المميزات',
        style: AppTypography.titleMedium,
      ),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: FeatureComparison.allFeatures.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        feature.nameAr,
                        style: AppTypography.body,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature.freeValue ?? '-',
                        style: AppTypography.caption.copyWith(
                          color: feature.freeValue == '✗' 
                              ? AppColors.textSecondary 
                              : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature.proValue ?? '-',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature.businessValue ?? '-',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    final price = _isYearly ? _selectedPlan.yearlyPrice : _selectedPlan.monthlyPrice;
    final period = _isYearly ? 'سنوياً' : 'شهرياً';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _subscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'اشترك في ${_selectedPlan.displayNameAr} - \$${price.toStringAsFixed(0)} $period',
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        Text(
          'يتجدد الاشتراك تلقائياً. يمكنك الإلغاء في أي وقت.',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Open terms
              },
              child: Text(
                'الشروط والأحكام',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {
                // Open privacy
              },
              child: Text(
                'سياسة الخصوصية',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);

    try {
      final productId = _isYearly 
          ? _selectedPlan.yearlyProductId 
          : _selectedPlan.monthlyProductId;

      if (productId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('منتج غير متوفر')),
        );
        return;
      }

      final service = ref.read(subscriptionServiceProvider);
      // Get business ID from provider
      // final businessId = ref.read(currentBusinessProvider).value?.id;
      
      // For now, show success message
      // In production, call: service.purchaseSubscription(productId, businessId)
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري معالجة الطلب...'),
          backgroundColor: AppColors.success,
        ),
      );

      // TODO: Implement actual purchase when app is on App Store
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.restorePurchases();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استعادة المشتريات'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
