/// Subscription plan types — aligned with AppConfig 4-tier pricing
enum PlanType {
  free,
  starter,
  growth,
  advanced;

  String get displayName {
    switch (this) {
      case PlanType.free:
        return 'Free';
      case PlanType.starter:
        return 'Starter';
      case PlanType.growth:
        return 'Growth';
      case PlanType.advanced:
        return 'Advanced';
    }
  }

  String get displayNameAr {
    switch (this) {
      case PlanType.free:
        return 'مجاني';
      case PlanType.starter:
        return 'أساسي';
      case PlanType.growth:
        return 'نمو';
      case PlanType.advanced:
        return 'متقدم';
    }
  }

  String get description {
    switch (this) {
      case PlanType.free:
        return 'Try all features with limits';
      case PlanType.starter:
        return 'Essential tools to get started';
      case PlanType.growth:
        return 'Perfect for growing businesses';
      case PlanType.advanced:
        return 'Unlimited everything for enterprises';
    }
  }

  String get descriptionAr {
    switch (this) {
      case PlanType.free:
        return 'جرب جميع المميزات بحدود';
      case PlanType.starter:
        return 'أدوات أساسية للبداية';
      case PlanType.growth:
        return 'مثالي للأعمال المتنامية';
      case PlanType.advanced:
        return 'بدون حدود للشركات الكبيرة';
    }
  }

  /// Apple StoreKit product identifiers
  String? get monthlyProductId {
    switch (this) {
      case PlanType.free:
        return null;
      case PlanType.starter:
        return 'loya_starter_monthly';
      case PlanType.growth:
        return 'loya_growth_monthly';
      case PlanType.advanced:
        return 'loya_advanced_monthly';
    }
  }

  String? get yearlyProductId {
    switch (this) {
      case PlanType.free:
        return null;
      case PlanType.starter:
        return 'loya_starter_yearly';
      case PlanType.growth:
        return 'loya_growth_yearly';
      case PlanType.advanced:
        return 'loya_advanced_yearly';
    }
  }

  /// Monthly prices in EUR
  double get monthlyPrice {
    switch (this) {
      case PlanType.free:
        return 0;
      case PlanType.starter:
        return 16;
      case PlanType.growth:
        return 33;
      case PlanType.advanced:
        return 66;
    }
  }

  /// Yearly prices in EUR (2 months free)
  double get yearlyPrice {
    switch (this) {
      case PlanType.free:
        return 0;
      case PlanType.starter:
        return 160;
      case PlanType.growth:
        return 330;
      case PlanType.advanced:
        return 660;
    }
  }

  /// Get plan from product ID
  static PlanType fromProductId(String productId) {
    if (productId.contains('advanced') || productId.contains('business')) {
      return PlanType.advanced;
    } else if (productId.contains('growth') || productId.contains('pro')) {
      return PlanType.growth;
    } else if (productId.contains('starter')) {
      return PlanType.starter;
    }
    return PlanType.free;
  }

  /// Get plan from string (for Firestore) — handles legacy plan names
  static PlanType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'starter':
        return PlanType.starter;
      case 'growth':
      case 'pro':
        return PlanType.growth;
      case 'advanced':
      case 'business':
        return PlanType.advanced;
      default:
        return PlanType.free;
    }
  }
}
