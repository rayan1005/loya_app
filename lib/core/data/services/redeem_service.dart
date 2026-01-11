import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

/// Result of a redeem operation
class RedeemResult {
  final bool success;
  final String message;
  final CustomerProgress? updatedProgress;
  final int? newStampCount;
  final int? totalRedeemed;

  const RedeemResult({
    required this.success,
    required this.message,
    this.updatedProgress,
    this.newStampCount,
    this.totalRedeemed,
  });

  factory RedeemResult.success({
    required CustomerProgress progress,
    required int newStamps,
    required int totalRedeemed,
  }) {
    return RedeemResult(
      success: true,
      message: 'تم استبدال المكافأة بنجاح!',
      updatedProgress: progress,
      newStampCount: newStamps,
      totalRedeemed: totalRedeemed,
    );
  }

  factory RedeemResult.error(String message) {
    return RedeemResult(
      success: false,
      message: message,
    );
  }
}

/// Service for handling reward redemption
class RedeemService {
  final FirebaseFirestore _firestore;

  RedeemService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Check if a customer has a reward available to redeem
  Future<bool> hasAvailableReward({
    required String customerId,
    required String programId,
  }) async {
    try {
      // Get customer progress
      final progressQuery = await _firestore
          .collection('customer_progress')
          .where('customerId', isEqualTo: customerId)
          .where('programId', isEqualTo: programId)
          .limit(1)
          .get();

      if (progressQuery.docs.isEmpty) {
        return false;
      }

      final progress = CustomerProgress.fromFirestore(progressQuery.docs.first);

      // Get program to check stamps required
      final programDoc = await _firestore
          .collection('programs')
          .doc(programId)
          .get();

      if (!programDoc.exists) {
        return false;
      }

      final program = LoyaltyProgram.fromFirestore(programDoc);
      
      return progress.stamps >= program.stampsRequired;
    } catch (e) {
      debugPrint('Error checking available reward: $e');
      return false;
    }
  }

  /// Calculate how many rewards are available for a customer
  Future<int> getAvailableRewardsCount({
    required String customerId,
    required String programId,
  }) async {
    try {
      final progressQuery = await _firestore
          .collection('customer_progress')
          .where('customerId', isEqualTo: customerId)
          .where('programId', isEqualTo: programId)
          .limit(1)
          .get();

      if (progressQuery.docs.isEmpty) {
        return 0;
      }

      final progress = CustomerProgress.fromFirestore(progressQuery.docs.first);

      final programDoc = await _firestore
          .collection('programs')
          .doc(programId)
          .get();

      if (!programDoc.exists) {
        return 0;
      }

      final program = LoyaltyProgram.fromFirestore(programDoc);
      
      // Calculate available rewards (stamps / required stamps)
      return progress.stamps ~/ program.stampsRequired;
    } catch (e) {
      debugPrint('Error getting available rewards: $e');
      return 0;
    }
  }

  /// Redeem a reward for a customer
  /// This deducts [stampsRequired] stamps and increments [rewardsRedeemed]
  Future<RedeemResult> redeemReward({
    required String businessId,
    required String customerId,
    required String programId,
    String? staffId,
    String? notes,
  }) async {
    try {
      // Get customer progress
      final progressQuery = await _firestore
          .collection('customer_progress')
          .where('customerId', isEqualTo: customerId)
          .where('programId', isEqualTo: programId)
          .limit(1)
          .get();

      if (progressQuery.docs.isEmpty) {
        return RedeemResult.error('العميل غير مسجل في هذا البرنامج');
      }

      final progressDoc = progressQuery.docs.first;
      final progress = CustomerProgress.fromFirestore(progressDoc);

      // Verify business ownership
      if (progress.businessId != businessId) {
        return RedeemResult.error('هذا العميل تابع لنشاط تجاري آخر');
      }

      // Get program details
      final programDoc = await _firestore
          .collection('programs')
          .doc(programId)
          .get();

      if (!programDoc.exists) {
        return RedeemResult.error('البرنامج غير موجود');
      }

      final program = LoyaltyProgram.fromFirestore(programDoc);

      // Check if customer has enough stamps
      if (progress.stamps < program.stampsRequired) {
        return RedeemResult.error(
          'العميل لا يملك أختام كافية (${progress.stamps}/${program.stampsRequired})'
        );
      }

      // Calculate new stamp count
      final newStampCount = progress.stamps - program.stampsRequired;
      final newRewardsRedeemed = progress.rewardsRedeemed + 1;
      final now = DateTime.now();

      // Update customer progress using transaction
      await _firestore.runTransaction((transaction) async {
        // Update progress
        transaction.update(progressDoc.reference, {
          'stamps': newStampCount,
          'rewardsRedeemed': newRewardsRedeemed,
          'updatedAt': Timestamp.fromDate(now),
        });

        // Log activity
        final activityRef = _firestore.collection('activity').doc();
        transaction.set(activityRef, {
          'businessId': businessId,
          'customerId': customerId,
          'programId': programId,
          'programName': program.name,
          'type': 'redeem',
          'previousStamps': progress.stamps,
          'newStamps': newStampCount,
          'rewardDescription': program.rewardDescription,
          'staffId': staffId,
          'notes': notes,
          'timestamp': Timestamp.fromDate(now),
        });

        // Update program stats
        transaction.update(programDoc.reference, {
          'totalRewards': FieldValue.increment(1),
        });
      });

      // Fetch updated progress
      final updatedProgressDoc = await progressDoc.reference.get();
      final updatedProgress = CustomerProgress.fromFirestore(updatedProgressDoc);

      return RedeemResult.success(
        progress: updatedProgress,
        newStamps: newStampCount,
        totalRedeemed: newRewardsRedeemed,
      );
    } catch (e) {
      debugPrint('Error redeeming reward: $e');
      return RedeemResult.error('حدث خطأ أثناء استبدال المكافأة: ${e.toString()}');
    }
  }

  /// Get redemption history for a customer
  Future<List<Map<String, dynamic>>> getRedemptionHistory({
    required String customerId,
    required String programId,
    int limit = 10,
  }) async {
    try {
      final query = await _firestore
          .collection('activity')
          .where('customerId', isEqualTo: customerId)
          .where('programId', isEqualTo: programId)
          .where('type', isEqualTo: 'redeem')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error fetching redemption history: $e');
      return [];
    }
  }
}

/// Provider for redeem service
final redeemServiceProvider = Provider<RedeemService>((ref) {
  return RedeemService();
});

/// Provider to check if a customer has available rewards
final hasAvailableRewardProvider = FutureProvider.family<bool, ({String customerId, String programId})>(
  (ref, params) async {
    final service = ref.read(redeemServiceProvider);
    return service.hasAvailableReward(
      customerId: params.customerId,
      programId: params.programId,
    );
  },
);

/// Provider to get available rewards count
final availableRewardsCountProvider = FutureProvider.family<int, ({String customerId, String programId})>(
  (ref, params) async {
    final service = ref.read(redeemServiceProvider);
    return service.getAvailableRewardsCount(
      customerId: params.customerId,
      programId: params.programId,
    );
  },
);
