import 'plan_type.dart';

/// Defines the limits for each subscription plan — 4-tier system
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

  /// Free plan — try everything with tight limits
  static const free = PlanLimits(
    maxCustomers: 50,
    maxStampsPerMonth: 100,
    maxPrograms: 1,
    maxTeamMembers: 1,
    maxLocations: 1,
    maxPushNotificationsPerMonth: 10,
    maxAutomationRules: 0,
    canRemoveBranding: false,
    hasApiAccess: false,
    hasPrioritySupport: false,
  );

  /// Starter plan — essential tools (€16/mo)
  static const starter = PlanLimits(
    maxCustomers: 200,
    maxStampsPerMonth: 1000,
    maxPrograms: 1,
    maxTeamMembers: 2,
    maxLocations: 1,
    maxPushNotificationsPerMonth: 50,
    maxAutomationRules: 0,
    canRemoveBranding: false,
    hasApiAccess: false,
    hasPrioritySupport: false,
  );

  /// Growth plan — for growing businesses (€33/mo)
  static const growth = PlanLimits(
    maxCustomers: 2000,
    maxStampsPerMonth: 10000,
    maxPrograms: 4,
    maxTeamMembers: 5,
    maxLocations: 4,
    maxPushNotificationsPerMonth: 500,
    maxAutomationRules: 5,
    canRemoveBranding: false,
    hasApiAccess: false,
    hasPrioritySupport: false,
  );

  /// Advanced plan — unlimited for enterprises (€66/mo)
  static const advanced = PlanLimits(
    maxCustomers: 999999,
    maxStampsPerMonth: 999999,
    maxPrograms: 999999,
    maxTeamMembers: 999999,
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
      case PlanType.starter:
        return starter;
      case PlanType.growth:
        return growth;
      case PlanType.advanced:
        return advanced;
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
  final String? starterValue;
  final String? growthValue;
  final String? advancedValue;
  final bool isBooleanFeature;

  const FeatureComparison({
    required this.nameEn,
    required this.nameAr,
    this.freeValue,
    this.starterValue,
    this.growthValue,
    this.advancedValue,
    this.isBooleanFeature = false,
  });

  /// All features for comparison table
  static List<FeatureComparison> get allFeatures => [
        FeatureComparison(
          nameEn: 'Customers',
          nameAr: 'العملاء',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxCustomers),
          starterValue: PlanLimits.formatLimit(PlanLimits.starter.maxCustomers),
          growthValue: PlanLimits.formatLimit(PlanLimits.growth.maxCustomers),
          advancedValue: PlanLimits.formatLimit(PlanLimits.advanced.maxCustomers),
        ),
        FeatureComparison(
          nameEn: 'Stamps/month',
          nameAr: 'الأختام/شهر',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxStampsPerMonth),
          starterValue: PlanLimits.formatLimit(PlanLimits.starter.maxStampsPerMonth),
          growthValue: PlanLimits.formatLimit(PlanLimits.growth.maxStampsPerMonth),
          advancedValue: PlanLimits.formatLimit(PlanLimits.advanced.maxStampsPerMonth),
        ),
        FeatureComparison(
          nameEn: 'Programs',
          nameAr: 'البرامج',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxPrograms),
          starterValue: PlanLimits.formatLimit(PlanLimits.starter.maxPrograms),
          growthValue: PlanLimits.formatLimit(PlanLimits.growth.maxPrograms),
          advancedValue: PlanLimits.formatLimit(PlanLimits.advanced.maxPrograms),
        ),
        FeatureComparison(
          nameEn: 'Team Members',
          nameAr: 'أعضاء الفريق',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxTeamMembers),
          starterValue: PlanLimits.formatLimit(PlanLimits.starter.maxTeamMembers),
          growthValue: PlanLimits.formatLimit(PlanLimits.growth.maxTeamMembers),
          advancedValue: PlanLimits.formatLimit(PlanLimits.advanced.maxTeamMembers),
        ),
        FeatureComparison(
          nameEn: 'Locations',
          nameAr: 'الفروع',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxLocations),
          starterValue: PlanLimits.formatLimit(PlanLimits.starter.maxLocations),
          growthValue: PlanLimits.formatLimit(PlanLimits.growth.maxLocations),
          advancedValue: PlanLimits.formatLimit(PlanLimits.advanced.maxLocations),
        ),
        FeatureComparison(
          nameEn: 'Push Notifications/month',
          nameAr: 'الإشعارات/شهر',
          freeValue: PlanLimits.formatLimit(PlanLimits.free.maxPushNotificationsPerMonth),
          starterValue: PlanLimits.formatLimit(PlanLimits.starter.maxPushNotificationsPerMonth),
          growthValue: PlanLimits.formatLimit(PlanLimits.growth.maxPushNotificationsPerMonth),
          advancedValue: PlanLimits.formatLimit(PlanLimits.advanced.maxPushNotificationsPerMonth),
        ),
        FeatureComparison(
          nameEn: 'Automation Rules',
          nameAr: 'قواعد الأتمتة',
          freeValue: '✗',
          starterValue: '✗',
          growthValue: PlanLimits.formatLimit(PlanLimits.growth.maxAutomationRules),
          advancedValue: PlanLimits.formatLimit(PlanLimits.advanced.maxAutomationRules),
        ),
        const FeatureComparison(
          nameEn: 'Apple Wallet',
          nameAr: 'محفظة Apple',
          freeValue: '✓',
          starterValue: '✓',
          growthValue: '✓',
          advancedValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Location Push',
          nameAr: 'إشعارات الموقع',
          freeValue: '✗',
          starterValue: '✓',
          growthValue: '✓',
          advancedValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Referral Program',
          nameAr: 'برنامج الإحالة',
          freeValue: '✗',
          starterValue: '✗',
          growthValue: '✓',
          advancedValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Remove Branding',
          nameAr: 'إزالة العلامة التجارية',
          freeValue: '✗',
          starterValue: '✗',
          growthValue: '✗',
          advancedValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'API Access',
          nameAr: 'الوصول للـ API',
          freeValue: '✗',
          starterValue: '✗',
          growthValue: '✗',
          advancedValue: '✓',
          isBooleanFeature: true,
        ),
        const FeatureComparison(
          nameEn: 'Priority Support',
          nameAr: 'دعم أولوي',
          freeValue: '✗',
          starterValue: 'Email',
          growthValue: 'Email',
          advancedValue: 'Phone + Email',
          isBooleanFeature: false,
        ),
      ];
}
