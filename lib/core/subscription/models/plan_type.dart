/// Subscription plan types
enum PlanType {
  free,
  pro,
  business;

  String get displayName {
    switch (this) {
      case PlanType.free:
        return 'Free';
      case PlanType.pro:
        return 'Pro';
      case PlanType.business:
        return 'Business';
    }
  }

  String get displayNameAr {
    switch (this) {
      case PlanType.free:
        return 'مجاني';
      case PlanType.pro:
        return 'احترافي';
      case PlanType.business:
        return 'أعمال';
    }
  }

  String get description {
    switch (this) {
      case PlanType.free:
        return 'Try all features with limits';
      case PlanType.pro:
        return 'Perfect for growing businesses';
      case PlanType.business:
        return 'Unlimited everything for enterprises';
    }
  }

  String get descriptionAr {
    switch (this) {
      case PlanType.free:
        return 'جرب جميع المميزات بحدود';
      case PlanType.pro:
        return 'مثالي للأعمال المتنامية';
      case PlanType.business:
        return 'بدون حدود للشركات الكبيرة';
    }
  }

  /// Apple StoreKit product identifiers
  String? get monthlyProductId {
    switch (this) {
      case PlanType.free:
        return null;
      case PlanType.pro:
        return 'loya_pro_monthly';
      case PlanType.business:
        return 'loya_business_monthly';
    }
  }

  String? get yearlyProductId {
    switch (this) {
      case PlanType.free:
        return null;
      case PlanType.pro:
        return 'loya_pro_yearly';
      case PlanType.business:
        return 'loya_business_yearly';
    }
  }

  /// Prices
  double get monthlyPrice {
    switch (this) {
      case PlanType.free:
        return 0;
      case PlanType.pro:
        return 19;
      case PlanType.business:
        return 39;
    }
  }

  double get yearlyPrice {
    switch (this) {
      case PlanType.free:
        return 0;
      case PlanType.pro:
        return 190; // 2 months free
      case PlanType.business:
        return 390; // 2 months free
    }
  }

  /// Get plan from product ID
  static PlanType fromProductId(String productId) {
    if (productId.contains('business')) {
      return PlanType.business;
    } else if (productId.contains('pro')) {
      return PlanType.pro;
    }
    return PlanType.free;
  }

  /// Get plan from string (for Firestore)
  static PlanType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pro':
        return PlanType.pro;
      case 'business':
        return PlanType.business;
      default:
        return PlanType.free;
    }
  }
}
