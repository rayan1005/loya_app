import 'package:cloud_firestore/cloud_firestore.dart';
import 'plan_type.dart';
import 'plan_limits.dart';

/// Represents a user's subscription status
class Subscription {
  final String id;
  final String businessId;
  final PlanType planType;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final bool isActive;
  final bool isTrial;
  final String? appleProductId;
  final String? appleTransactionId;
  final String? appleOriginalTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Usage tracking (reset monthly)
  final int stampsUsedThisMonth;
  final int pushNotificationsSentThisMonth;
  final DateTime? usageResetDate;

  const Subscription({
    required this.id,
    required this.businessId,
    required this.planType,
    this.startDate,
    this.endDate,
    this.trialEndDate,
    required this.isActive,
    this.isTrial = false,
    this.appleProductId,
    this.appleTransactionId,
    this.appleOriginalTransactionId,
    required this.createdAt,
    required this.updatedAt,
    this.stampsUsedThisMonth = 0,
    this.pushNotificationsSentThisMonth = 0,
    this.usageResetDate,
  });

  /// Get the limits for this subscription's plan
  PlanLimits get limits => PlanLimits.forPlan(planType);

  /// Check if subscription is expired
  bool get isExpired {
    if (planType == PlanType.free) return false;
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Check if trial is expired
  bool get isTrialExpired {
    if (!isTrial) return false;
    if (trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }

  /// Get effective plan (free if expired)
  PlanType get effectivePlan {
    if (isExpired || isTrialExpired) return PlanType.free;
    return planType;
  }

  /// Get effective limits (free limits if expired)
  PlanLimits get effectiveLimits => PlanLimits.forPlan(effectivePlan);

  /// Days remaining in subscription
  int? get daysRemaining {
    if (planType == PlanType.free) return null;
    final end = isTrial ? trialEndDate : endDate;
    if (end == null) return null;
    final remaining = end.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if can add more customers
  bool canAddCustomer(int currentCount) {
    return currentCount < effectiveLimits.maxCustomers;
  }

  /// Check if can add more stamps this month
  bool canAddStamp() {
    return stampsUsedThisMonth < effectiveLimits.maxStampsPerMonth;
  }

  /// Check if can create more programs
  bool canCreateProgram(int currentCount) {
    return currentCount < effectiveLimits.maxPrograms;
  }

  /// Check if can add more team members
  bool canAddTeamMember(int currentCount) {
    return currentCount < effectiveLimits.maxTeamMembers;
  }

  /// Check if can add more locations
  bool canAddLocation(int currentCount) {
    return currentCount < effectiveLimits.maxLocations;
  }

  /// Check if can send more push notifications this month
  bool canSendPushNotification() {
    return pushNotificationsSentThisMonth < effectiveLimits.maxPushNotificationsPerMonth;
  }

  /// Check if can create more automation rules
  bool canCreateAutomationRule(int currentCount) {
    return currentCount < effectiveLimits.maxAutomationRules;
  }

  /// Create default free subscription for new business
  factory Subscription.free(String businessId) {
    final now = DateTime.now();
    return Subscription(
      id: '',
      businessId: businessId,
      planType: PlanType.free,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create trial subscription
  factory Subscription.trial(String businessId, PlanType plan) {
    final now = DateTime.now();
    return Subscription(
      id: '',
      businessId: businessId,
      planType: plan,
      startDate: now,
      trialEndDate: now.add(const Duration(days: 7)),
      isActive: true,
      isTrial: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      planType: PlanType.fromString(data['planType']),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      trialEndDate: (data['trialEndDate'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? false,
      isTrial: data['isTrial'] ?? false,
      appleProductId: data['appleProductId'],
      appleTransactionId: data['appleTransactionId'],
      appleOriginalTransactionId: data['appleOriginalTransactionId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stampsUsedThisMonth: data['stampsUsedThisMonth'] ?? 0,
      pushNotificationsSentThisMonth: data['pushNotificationsSentThisMonth'] ?? 0,
      usageResetDate: (data['usageResetDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'planType': planType.name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'trialEndDate': trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
      'isActive': isActive,
      'isTrial': isTrial,
      'appleProductId': appleProductId,
      'appleTransactionId': appleTransactionId,
      'appleOriginalTransactionId': appleOriginalTransactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'stampsUsedThisMonth': stampsUsedThisMonth,
      'pushNotificationsSentThisMonth': pushNotificationsSentThisMonth,
      'usageResetDate': usageResetDate != null ? Timestamp.fromDate(usageResetDate!) : null,
    };
  }

  Subscription copyWith({
    String? id,
    String? businessId,
    PlanType? planType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    bool? isActive,
    bool? isTrial,
    String? appleProductId,
    String? appleTransactionId,
    String? appleOriginalTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? stampsUsedThisMonth,
    int? pushNotificationsSentThisMonth,
    DateTime? usageResetDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      isActive: isActive ?? this.isActive,
      isTrial: isTrial ?? this.isTrial,
      appleProductId: appleProductId ?? this.appleProductId,
      appleTransactionId: appleTransactionId ?? this.appleTransactionId,
      appleOriginalTransactionId: appleOriginalTransactionId ?? this.appleOriginalTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stampsUsedThisMonth: stampsUsedThisMonth ?? this.stampsUsedThisMonth,
      pushNotificationsSentThisMonth: pushNotificationsSentThisMonth ?? this.pushNotificationsSentThisMonth,
      usageResetDate: usageResetDate ?? this.usageResetDate,
    );
  }
}
