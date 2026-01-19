import 'plan_type.dart';

/// Defines the limits for each subscription plan
class PlanLimits {
  final int maxCustomers;
  final int maxStampsPerMonth;
  final int maxPrograms;
  final int maxTeamMembers;
  final int maxLocations;
  final int maxPushNotificationsPerMonth;
  final int maxAutomationRules;
  final bool canRemoveBranding;
  final bool hasApiAccess;
  final bool hasPrioritySupport;

  const PlanLimits({
    required this.maxCustomers,
    required this.maxStampsPerMonth,
    required this.maxPrograms,
    required this.maxTeamMembers,
    required this.maxLocations,
    required this.maxPushNotificationsPerMonth,
    required this.maxAutomationRules,
    required this.canRemoveBranding,
    required this.hasApiAccess,
    required this.hasPrioritySupport,
  });

  /// Free plan - try everything with tight limits
  static const free = PlanLimits(
    maxCustomers: 50,
    maxStampsPerMonth: 100,
    maxPrograms: 1,
    maxTeamMembers: 1,
    maxLocations: 1,
    maxPushNotificationsPerMonth: 10,
    maxAutomationRules: 1,
    canRemoveBranding: false,
    hasApiAccess: false,
    hasPrioritySupport: false,
  );

  /// Pro plan - for growing businesses
  static const pro = PlanLimits(
    maxCustomers: 1000,
    maxStampsPerMonth: 5000,
    maxPrograms: 3,
    maxTeamMembers: 3,
    maxLocations: 3,
    maxPushNotificationsPerMonth: 500,
    maxAutomationRules: 5,
    canRemoveBranding: false,
    hasApiAccess: false,
    hasPrioritySupport: false,
  );

  /// Business plan - unlimited for enterprises
  static const business = PlanLimits(
    maxCustomers: 999999, // Effectively unlimited
    maxStampsPerMonth: 999999,
    maxPrograms: 999999,
    maxTeamMembers: 10,
    maxLocations: 999999,
    maxPushNotificationsPerMonth: 999999,
    maxAutomationRules: 999999,
    canRemoveBranding: true,
    hasApiAccess: true,
    hasPrioritySupport: true,
  );

  /// Get limits for a plan type
  static PlanLimits forPlan(PlanType plan) {
    switch (plan) {
      case PlanType.free:
        return free;
      case PlanType.pro:
        return pro;
      case PlanType.business:
        return business;
    }
  }

  /// Check if a value is at the "unlimited" level
  static bool isUnlimited(int value) => value >= 999999;

  /// Format limit for display
  static String formatLimit(int value) {
    if (isUnlimited(value)) {
      return '∞';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return value.toString();
  }

  /// Format limit for display in Arabic
  static String formatLimitAr(int value) {
    if (isUnlimited(value)) {
      return 'غير محدود';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)} ألف';
    }
    return value.toString();
  }
}

/// Feature comparison item for UI
class FeatureComparison {
  final String nameEn;
  final String nameAr;
  final String? freeValue;
  final String? proValue;
  final String? businessValue;
  final bool isBooleanFeature;

  const FeatureComparison({
    required this.nameEn,
    required this.nameAr,
    this.freeValue,
    this.proValue,
    this.businessValue,
    this.isBooleanFeature = false,
  });

  /// All features for comparison table
  static List<FeatureComparison> get allFeatures => [
        FeatureComparison(
          nameEn: 'Customers',
          nameAr: 'العملاء',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxCustomers),
          proValue: PlanLimits.formatLimit(PlanLimits.pro.maxCustomers),
          businessValue: PlanLimits.formatLimit(PlanLimits.business.maxCustomers),
        ),
        FeatureComparison(
          nameEn: 'Stamps/month',
          nameAr: 'الأختام/شهر',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxStampsPerMonth),
          proValue: PlanLimits.formatLimit(PlanLimits.pro.maxStampsPerMonth),
          businessValue: PlanLimits.formatLimit(PlanLimits.business.maxStampsPerMonth),
        ),
        FeatureComparison(
          nameEn: 'Programs',
          nameAr: 'البرامج',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxPrograms),
          proValue: PlanLimits.formatLimit(PlanLimits.pro.maxPrograms),
          businessValue: PlanLimits.formatLimit(PlanLimits.business.maxPrograms),
        ),
        FeatureComparison(
          nameEn: 'Team Members',
          nameAr: 'أعضاء الفريق',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxTeamMembers),
          proValue: PlanLimits.formatLimit(PlanLimits.pro.maxTeamMembers),
          businessValue: PlanLimits.formatLimit(PlanLimits.business.maxTeamMembers),
        ),
        FeatureComparison(
          nameEn: 'Locations',
          nameAr: 'الفروع',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxLocations),
          proValue: PlanLimits.formatLimit(PlanLimits.pro.maxLocations),
          businessValue: PlanLimits.formatLimit(PlanLimits.business.maxLocations),
        ),
        FeatureComparison(
          nameEn: 'Push Notifications/month',
          nameAr: 'الإشعارات/شهر',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxPushNotificationsPerMonth),
          proValue: PlanLimits.formatLimit(PlanLimits.pro.maxPushNotificationsPerMonth),
          businessValue: PlanLimits.formatLimit(PlanLimits.business.maxPushNotificationsPerMonth),
        ),
        FeatureComparison(
          nameEn: 'Automation Rules',
          nameAr: 'قواعد الأتمتة',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxAutomationRules),
          proValue: PlanLimits.formatLimit(PlanLimits.pro.maxAutomationRules),
          businessValue: PlanLimits.formatLimit(PlanLimits.business.maxAutomationRules),
        ),
        const FeatureComparison(
          nameEn: 'Analytics',
          nameAr: 'التحليلات',
          freeValue: '✓',
          proValue: '✓',
          businessValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Apple Wallet',
          nameAr: 'محفظة Apple',
          freeValue: '✓',
          proValue: '✓',
          businessValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Custom Pass Design',
          nameAr: 'تصميم البطاقة',
          freeValue: '✓',
          proValue: '✓',
          businessValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Birthday Rewards',
          nameAr: 'مكافآت أعياد الميلاد',
          freeValue: '✓',
          proValue: '✓',
          businessValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Export Data',
          nameAr: 'تصدير البيانات',
          freeValue: '✓',
          proValue: '✓',
          businessValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Remove Branding',
          nameAr: 'إزالة العلامة التجارية',
          freeValue: '✗',
          proValue: '✗',
          businessValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'API Access',
          nameAr: 'الوصول للـ API',
          freeValue: '✗',
          proValue: '✗',
          businessValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Priority Support',
          nameAr: 'دعم أولوي',
          freeValue: '✗',
          proValue: 'Email',
          businessValue: 'Phone + Email',
          isBooleanFeature: false,
        ),
      ];
}
