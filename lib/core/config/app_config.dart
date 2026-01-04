/// App-wide constants and configuration
class AppConfig {
  AppConfig._();

  // API
  static const String apiBaseUrl = 'https://api-v4xex7aj3a-uc.a.run.app';
  static const String webDomain = 'loya.live';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration otpTimeout = Duration(seconds: 60);
  static const int otpResendDelay = 60; // seconds

  // Limits
  static const int maxStampsPerProgram = 12;
  static const int maxProgramNameLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxBroadcastMessageLength = 150;

  // Phone
  static const String defaultCountryCode = 'SA';
  static const List<String> supportedCountryCodes = [
    'SA',
    'AE',
    'KW',
    'BH',
    'OM',
    'QA',
    'EG',
    'JO'
  ];

  // Pricing (EUR per month, billed annually)
  static const int starterPlanPrice = 16;
  static const int growthPlanPrice = 33;
  static const int advancedPlanPrice = 66;
  static const String currency = 'EUR';

  // Colors (Apple-inspired palette for programs)
  static const List<String> programColors = [
    '#007AFF', // Blue
    '#34C759', // Green
    '#FF9500', // Orange
    '#FF3B30', // Red
    '#AF52DE', // Purple
    '#5856D6', // Indigo
    '#00C7BE', // Teal
    '#FF2D55', // Pink
  ];

  // Plan definitions with features
  static const Map<String, PlanConfig> plans = {
    'free': PlanConfig(
      id: 'free',
      nameKey: 'free_plan',
      price: 0,
      limits: PlanLimits(
        programs: 1,
        passes: 50,
        branches: 1,
        teamMembers: 1,
      ),
      features: [
        PlanFeature.unlimitedCustomers,
        PlanFeature.cardDesign,
        PlanFeature.basicAnalytics,
      ],
    ),
    'starter': PlanConfig(
      id: 'starter',
      nameKey: 'starter_plan',
      price: starterPlanPrice,
      limits: PlanLimits(
        programs: 1,
        passes: -1,
        branches: 1,
        teamMembers: -1,
      ),
      features: [
        PlanFeature.unlimitedCustomers,
        PlanFeature.cardDesign,
        PlanFeature.cardCustomization,
        PlanFeature.multiLanguage,
        PlanFeature.reviewCollection,
        PlanFeature.locationPush,
        PlanFeature.basicAnalytics,
      ],
    ),
    'growth': PlanConfig(
      id: 'growth',
      nameKey: 'growth_plan',
      price: growthPlanPrice,
      limits: PlanLimits(
        programs: 4,
        passes: -1,
        branches: 4,
        teamMembers: -1,
      ),
      features: [
        PlanFeature.unlimitedCustomers,
        PlanFeature.cardDesign,
        PlanFeature.cardCustomization,
        PlanFeature.multiLanguage,
        PlanFeature.reviewCollection,
        PlanFeature.locationPush,
        PlanFeature.basicAnalytics,
        PlanFeature.customFormFields,
        PlanFeature.tieredMembership,
        PlanFeature.referralProgram,
        PlanFeature.pushMarketing,
        PlanFeature.automatedPush,
      ],
    ),
    'advanced': PlanConfig(
      id: 'advanced',
      nameKey: 'advanced_plan',
      price: advancedPlanPrice,
      limits: PlanLimits(
        programs: 10,
        passes: -1,
        branches: 10,
        teamMembers: -1,
      ),
      features: [
        PlanFeature.unlimitedCustomers,
        PlanFeature.cardDesign,
        PlanFeature.cardCustomization,
        PlanFeature.multiLanguage,
        PlanFeature.reviewCollection,
        PlanFeature.locationPush,
        PlanFeature.basicAnalytics,
        PlanFeature.customFormFields,
        PlanFeature.tieredMembership,
        PlanFeature.referralProgram,
        PlanFeature.pushMarketing,
        PlanFeature.automatedPush,
        PlanFeature.emailMarketing,
        PlanFeature.smsMarketing,
        PlanFeature.thirdPartyIntegrations,
        PlanFeature.webhookApi,
        PlanFeature.prioritySupport,
      ],
    ),
  };

  // Admin/test phone numbers with full access (store all variants for matching)
  static const Set<String> _adminPhones = {
    '+966888888888',
    '966888888888',
    '0888888888',
    '888888888',
  };

  /// Check if a phone number has admin/full access
  static bool isAdminPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Clean the phone - remove all non-digits
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Extract the core number (last 9 digits for Saudi numbers)
    String coreNumber = digitsOnly.length >= 9
        ? digitsOnly.substring(digitsOnly.length - 9)
        : digitsOnly;

    // Check if the core number matches any admin phone core
    for (final adminPhone in _adminPhones) {
      String adminDigits = adminPhone.replaceAll(RegExp(r'[^\d]'), '');
      String adminCore = adminDigits.length >= 9
          ? adminDigits.substring(adminDigits.length - 9)
          : adminDigits;
      if (coreNumber == adminCore) {
        return true;
      }
    }
    return false;
  }

  /// Get effective plan for a business (returns 'advanced' for admin phones)
  static String getEffectivePlan(String? businessPlan, String? businessPhone) {
    if (isAdminPhone(businessPhone)) {
      return 'advanced'; // Full access for admin phones
    }
    return businessPlan ?? 'free';
  }

  /// Get minimum plan required for a feature
  static String? getMinimumPlanForFeature(PlanFeature feature) {
    for (final planId in ['free', 'starter', 'growth', 'advanced']) {
      final plan = plans[planId];
      if (plan != null && plan.features.contains(feature)) {
        return planId;
      }
    }
    return null;
  }

  /// Check if a plan has a feature
  static bool planHasFeature(String planId, PlanFeature feature) {
    final plan = plans[planId];
    if (plan == null) return false;
    return plan.features.contains(feature);
  }

  /// Check if a business has access to a feature (considers admin override)
  static bool businessHasFeature(
      String? planId, String? businessPhone, PlanFeature feature) {
    final effectivePlan = getEffectivePlan(planId, businessPhone);
    return planHasFeature(effectivePlan, feature);
  }
}

/// All available features that can be gated by plan
enum PlanFeature {
  // Core
  unlimitedCustomers,
  cardDesign,
  cardCustomization,
  multiLanguage,
  basicAnalytics,

  // Starter+
  reviewCollection,
  locationPush,

  // Growth+
  customFormFields,
  tieredMembership,
  referralProgram,
  pushMarketing,
  automatedPush,

  // Advanced
  emailMarketing,
  smsMarketing,
  thirdPartyIntegrations,
  webhookApi,
  prioritySupport,
}

/// Feature metadata for UI display
extension PlanFeatureExtension on PlanFeature {
  String get nameKey {
    switch (this) {
      case PlanFeature.unlimitedCustomers:
        return 'feature_unlimited_customers';
      case PlanFeature.cardDesign:
        return 'feature_card_design';
      case PlanFeature.cardCustomization:
        return 'feature_card_customization';
      case PlanFeature.multiLanguage:
        return 'feature_multi_language';
      case PlanFeature.basicAnalytics:
        return 'feature_basic_analytics';
      case PlanFeature.reviewCollection:
        return 'feature_review_collection';
      case PlanFeature.locationPush:
        return 'feature_location_push';
      case PlanFeature.customFormFields:
        return 'feature_custom_fields';
      case PlanFeature.tieredMembership:
        return 'feature_tiered_membership';
      case PlanFeature.referralProgram:
        return 'feature_referral_program';
      case PlanFeature.pushMarketing:
        return 'feature_push_marketing';
      case PlanFeature.automatedPush:
        return 'feature_automated_push';
      case PlanFeature.emailMarketing:
        return 'feature_email_marketing';
      case PlanFeature.smsMarketing:
        return 'feature_sms_marketing';
      case PlanFeature.thirdPartyIntegrations:
        return 'feature_integrations';
      case PlanFeature.webhookApi:
        return 'feature_webhook_api';
      case PlanFeature.prioritySupport:
        return 'feature_priority_support';
    }
  }

  String get iconName {
    switch (this) {
      case PlanFeature.unlimitedCustomers:
        return 'users';
      case PlanFeature.cardDesign:
        return 'credit_card';
      case PlanFeature.cardCustomization:
        return 'palette';
      case PlanFeature.multiLanguage:
        return 'globe';
      case PlanFeature.basicAnalytics:
        return 'bar_chart_2';
      case PlanFeature.reviewCollection:
        return 'star';
      case PlanFeature.locationPush:
        return 'map_pin';
      case PlanFeature.customFormFields:
        return 'file_text';
      case PlanFeature.tieredMembership:
        return 'award';
      case PlanFeature.referralProgram:
        return 'gift';
      case PlanFeature.pushMarketing:
        return 'bell';
      case PlanFeature.automatedPush:
        return 'zap';
      case PlanFeature.emailMarketing:
        return 'mail';
      case PlanFeature.smsMarketing:
        return 'message_square';
      case PlanFeature.thirdPartyIntegrations:
        return 'plug';
      case PlanFeature.webhookApi:
        return 'code';
      case PlanFeature.prioritySupport:
        return 'headphones';
    }
  }
}

class PlanConfig {
  final String id;
  final String nameKey;
  final int price;
  final PlanLimits limits;
  final List<PlanFeature> features;

  const PlanConfig({
    required this.id,
    required this.nameKey,
    required this.price,
    required this.limits,
    required this.features,
  });

  bool hasFeature(PlanFeature feature) => features.contains(feature);
}

class PlanLimits {
  final int programs; // -1 = unlimited
  final int passes; // -1 = unlimited
  final int branches; // -1 = unlimited
  final int teamMembers; // -1 = unlimited

  const PlanLimits({
    required this.programs,
    required this.passes,
    required this.branches,
    this.teamMembers = 1,
  });

  bool get hasUnlimitedPrograms => programs == -1;
  bool get hasUnlimitedPasses => passes == -1;
  bool get hasUnlimitedBranches => branches == -1;
  bool get hasUnlimitedTeamMembers => teamMembers == -1;
}
