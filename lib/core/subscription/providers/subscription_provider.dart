import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import '../services/subscription_service.dart';
import '../../data/providers/data_providers.dart';

/// Provider for SubscriptionService singleton
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Provider for current business subscription
final subscriptionProvider = StreamProvider<Subscription?>((ref) {
  final business = ref.watch(currentBusinessProvider).valueOrNull;
  if (business == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('subscriptions')
      .where('businessId', isEqualTo: business.id)
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) {
      // Return a default free subscription
      return Subscription.free(business.id);
    }
    return Subscription.fromFirestore(snapshot.docs.first);
  });
});

/// Provider for current plan limits
final planLimitsProvider = Provider<PlanLimits>((ref) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.effectiveLimits ?? PlanLimits.free;
});

/// Provider for current plan type
final currentPlanProvider = Provider<PlanType>((ref) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.effectivePlan ?? PlanType.free;
});

/// Provider to check if user can add a customer
final canAddCustomerProvider = Provider.family<bool, int>((ref, currentCount) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.canAddCustomer(currentCount) ?? 
         currentCount < PlanLimits.free.maxCustomers;
});

/// Provider to check if user can add a stamp
final canAddStampProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.canAddStamp() ?? true;
});

/// Provider to check if user can create a program
final canCreateProgramProvider = Provider.family<bool, int>((ref, currentCount) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.canCreateProgram(currentCount) ?? 
         currentCount < PlanLimits.free.maxPrograms;
});

/// Provider to check if user can add a team member
final canAddTeamMemberProvider = Provider.family<bool, int>((ref, currentCount) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.canAddTeamMember(currentCount) ?? 
         currentCount < PlanLimits.free.maxTeamMembers;
});

/// Provider to check if user can add a location
final canAddLocationProvider = Provider.family<bool, int>((ref, currentCount) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.canAddLocation(currentCount) ?? 
         currentCount < PlanLimits.free.maxLocations;
});

/// Provider to check if user can send push notification
final canSendPushNotificationProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.canSendPushNotification() ?? 
         true; // Allow by default, will track usage server-side
});

/// Provider to check if user can create automation rule
final canCreateAutomationRuleProvider = Provider.family<bool, int>((ref, currentCount) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  return subscription?.canCreateAutomationRule(currentCount) ?? 
         currentCount < PlanLimits.free.maxAutomationRules;
});

/// Provider for subscription status info
final subscriptionStatusProvider = Provider<SubscriptionStatus>((ref) {
  final subscription = ref.watch(subscriptionProvider).valueOrNull;
  
  if (subscription == null) {
    return SubscriptionStatus(
      plan: PlanType.free,
      isActive: true,
      isTrial: false,
      daysRemaining: null,
    );
  }
  
  return SubscriptionStatus(
    plan: subscription.effectivePlan,
    isActive: subscription.isActive && !subscription.isExpired,
    isTrial: subscription.isTrial,
    daysRemaining: subscription.daysRemaining,
    isTrialExpired: subscription.isTrialExpired,
    isExpired: subscription.isExpired,
  );
});

/// Helper class for subscription status display
class SubscriptionStatus {
  final PlanType plan;
  final bool isActive;
  final bool isTrial;
  final int? daysRemaining;
  final bool isTrialExpired;
  final bool isExpired;

  SubscriptionStatus({
    required this.plan,
    required this.isActive,
    required this.isTrial,
    this.daysRemaining,
    this.isTrialExpired = false,
    this.isExpired = false,
  });

  String get statusText {
    if (plan == PlanType.free) return 'Free Plan';
    if (isTrialExpired) return 'Trial Expired';
    if (isExpired) return 'Subscription Expired';
    if (isTrial && daysRemaining != null) {
      return 'Trial - $daysRemaining days left';
    }
    if (daysRemaining != null) {
      return '${plan.displayName} - $daysRemaining days left';
    }
    return plan.displayName;
  }

  String get statusTextAr {
    if (plan == PlanType.free) return 'الباقة المجانية';
    if (isTrialExpired) return 'انتهت الفترة التجريبية';
    if (isExpired) return 'انتهى الاشتراك';
    if (isTrial && daysRemaining != null) {
      return 'تجريبي - $daysRemaining يوم متبقي';
    }
    if (daysRemaining != null) {
      return '${plan.displayNameAr} - $daysRemaining يوم متبقي';
    }
    return plan.displayNameAr;
  }

  bool get shouldShowUpgrade {
    return plan == PlanType.free || isTrialExpired || isExpired;
  }
}
