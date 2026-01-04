import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference<Map<String, dynamic>> get _businessesRef =>
      _db.collection('businesses');

  CollectionReference<Map<String, dynamic>> get _programsRef =>
      _db.collection('programs');

  CollectionReference<Map<String, dynamic>> get _customersRef =>
      _db.collection('customers');

  CollectionReference<Map<String, dynamic>> get _progressRef =>
      _db.collection('customerProgress');

  CollectionReference<Map<String, dynamic>> get _activityRef =>
      _db.collection('activity_log');

  // ==================== Business ====================

  Future<Business?> getBusiness(String businessId) async {
    final doc = await _businessesRef.doc(businessId).get();
    if (!doc.exists) return null;
    return Business.fromFirestore(doc);
  }

  Future<Business?> getBusinessByOwner(String ownerId) async {
    final query = await _businessesRef
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return Business.fromFirestore(query.docs.first);
  }

  Future<String> createBusiness(Business business) async {
    final doc = await _businessesRef.add(business.toFirestore());
    return doc.id;
  }

  Future<void> updateBusiness(
      String businessId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _businessesRef.doc(businessId).update(data);
  }

  Stream<Business?> watchBusiness(String businessId) {
    return _businessesRef.doc(businessId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Business.fromFirestore(doc);
    });
  }

  /// Find team member by phone number across all businesses
  /// Returns (businessId, teamMemberData) if found, null otherwise
  Future<({String businessId, TeamMember member})?> findTeamMemberByPhone(String phone) async {
    // Normalize phone for searching
    final phoneVariants = _getPhoneVariants(phone);
    
    // Get all businesses and check their team_members subcollection
    final businessesQuery = await _businessesRef.get();
    
    for (final bizDoc in businessesQuery.docs) {
      final teamMembersRef = _businessesRef.doc(bizDoc.id).collection('team_members');
      
      for (final phoneVar in phoneVariants) {
        final memberQuery = await teamMembersRef
            .where('phone', isEqualTo: phoneVar)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();
        
        if (memberQuery.docs.isNotEmpty) {
          return (
            businessId: bizDoc.id,
            member: TeamMember.fromFirestore(memberQuery.docs.first),
          );
        }
      }
    }
    
    return null;
  }

  /// Check if a phone number is already a business owner
  Future<bool> isPhoneBusinessOwner(String phone) async {
    final phoneVariants = _getPhoneVariants(phone);
    
    for (final phoneVar in phoneVariants) {
      final query = await _businessesRef
          .where('phone', isEqualTo: phoneVar)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if phone exists in team members of a specific business
  Future<bool> isPhoneTeamMember(String businessId, String phone) async {
    final phoneVariants = _getPhoneVariants(phone);
    final teamMembersRef = _businessesRef.doc(businessId).collection('team_members');
    
    for (final phoneVar in phoneVariants) {
      final query = await teamMembersRef
          .where('phone', isEqualTo: phoneVar)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return true;
      }
    }
    
    return false;
  }

  /// Delete user account and all associated data
  Future<void> deleteUserAccount(String userId, String? businessId, bool isOwner) async {
    final batch = _db.batch();
    
    if (isOwner && businessId != null) {
      // Delete all programs
      final programsQuery = await _programsRef.where('businessId', isEqualTo: businessId).get();
      for (final doc in programsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all customers
      final customersQuery = await _customersRef.where('businessId', isEqualTo: businessId).get();
      for (final doc in customersQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all customer progress
      final progressQuery = await _progressRef.where('businessId', isEqualTo: businessId).get();
      for (final doc in progressQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all activity logs
      final activityQuery = await _activityRef.where('businessId', isEqualTo: businessId).get();
      for (final doc in activityQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete team members subcollection
      final teamMembersQuery = await _businessesRef.doc(businessId).collection('team_members').get();
      for (final doc in teamMembersQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the business itself
      batch.delete(_businessesRef.doc(businessId));
    }
    
    await batch.commit();
  }

  /// Helper to generate phone variants for searching
  List<String> _getPhoneVariants(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final variants = <String>{};
    
    // Add original
    variants.add(phone);
    
    // Add with/without + prefix
    if (phone.startsWith('+')) {
      variants.add(phone.substring(1));
    } else {
      variants.add('+$phone');
    }
    
    // Saudi Arabia specific variants
    if (digits.length >= 9) {
      final last9 = digits.substring(digits.length - 9);
      variants.add('+966$last9');
      variants.add('966$last9');
      variants.add('0$last9');
      variants.add(last9);
    }
    
    return variants.toList();
  }

  // ==================== Programs ====================

  Future<List<LoyaltyProgram>> getPrograms(String businessId) async {
    final query = await _programsRef
        .where('businessId', isEqualTo: businessId)
        .get();

    final programs = query.docs.map((doc) => LoyaltyProgram.fromFirestore(doc)).toList();
    // Sort client-side to avoid index requirement
    programs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return programs;
  }

  Future<LoyaltyProgram?> getProgram(String programId) async {
    final doc = await _programsRef.doc(programId).get();
    if (!doc.exists) return null;
    return LoyaltyProgram.fromFirestore(doc);
  }

  Future<String> createProgram(LoyaltyProgram program) async {
    final doc = await _programsRef.add(program.toFirestore());
    return doc.id;
  }

  Future<void> updateProgram(
      String programId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _programsRef.doc(programId).update(data);
  }

  Future<void> deleteProgram(String programId) async {
    await _programsRef.doc(programId).delete();
  }

  Stream<List<LoyaltyProgram>> watchPrograms(String businessId) {
    return _programsRef
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) {
          final programs = snapshot.docs
              .map((doc) => LoyaltyProgram.fromFirestore(doc))
              .toList();
          // Sort client-side to avoid index requirement
          programs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return programs;
        });
  }

  // ==================== Customers ====================

  Future<List<Customer>> getCustomers(String businessId, {int? limit}) async {
    final query = _customersRef
        .where('businessId', isEqualTo: businessId);

    final result = await query.get();
    final customers = result.docs.map((doc) => Customer.fromFirestore(doc)).toList();
    
    // Sort client-side to avoid index requirement
    customers.sort((a, b) {
      final aVisit = a.lastVisit ?? DateTime(2000);
      final bVisit = b.lastVisit ?? DateTime(2000);
      return bVisit.compareTo(aVisit);
    });
    
    if (limit != null && customers.length > limit) {
      return customers.sublist(0, limit);
    }
    return customers;
  }

  Future<Customer?> getCustomer(String customerId) async {
    final doc = await _customersRef.doc(customerId).get();
    if (!doc.exists) return null;
    return Customer.fromFirestore(doc);
  }

  Future<Customer?> getCustomerByPhone(String businessId, String phone) async {
    final query = await _customersRef
        .where('businessId', isEqualTo: businessId)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return Customer.fromFirestore(query.docs.first);
  }

  Future<String> createCustomer(Customer customer) async {
    final doc = await _customersRef.add(customer.toFirestore());
    return doc.id;
  }

  Future<void> updateCustomer(
      String customerId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _customersRef.doc(customerId).update(data);
  }

  Stream<List<Customer>> watchCustomers(String businessId) {
    return _customersRef
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) {
          final customers = snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
          // Sort client-side to avoid index requirement
          customers.sort((a, b) {
            final aVisit = a.lastVisit ?? DateTime(2000);
            final bVisit = b.lastVisit ?? DateTime(2000);
            return bVisit.compareTo(aVisit);
          });
          return customers;
        });
  }

  Future<List<Customer>> searchCustomers(
    String businessId,
    String query,
  ) async {
    // Search by phone (prefix match)
    final result = await _customersRef
        .where('businessId', isEqualTo: businessId)
        .where('phone', isGreaterThanOrEqualTo: query)
        .where('phone', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return result.docs.map((doc) => Customer.fromFirestore(doc)).toList();
  }

  // ==================== Customer Progress ====================

  Future<CustomerProgress?> getProgress(
    String customerId,
    String programId,
  ) async {
    final query = await _progressRef
        .where('customerId', isEqualTo: customerId)
        .where('programId', isEqualTo: programId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return CustomerProgress.fromFirestore(query.docs.first);
  }

  Future<String> createProgress(CustomerProgress progress) async {
    final doc = await _progressRef.add(progress.toFirestore());
    return doc.id;
  }

  Future<void> updateProgress(
      String progressId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _progressRef.doc(progressId).update(data);
  }

  Future<List<CustomerProgress>> getCustomerProgresses(
      String customerId) async {
    final query =
        await _progressRef.where('customerId', isEqualTo: customerId).get();

    return query.docs
        .map((doc) => CustomerProgress.fromFirestore(doc))
        .toList();
  }

  // ==================== Activity ====================

  Future<List<ActivityLog>> getActivity(
    String businessId, {
    int limit = 50,
    ActivityType? type,
  }) async {
    var query = _activityRef.where('businessId', isEqualTo: businessId);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    final result =
        await query.orderBy('timestamp', descending: true).limit(limit).get();

    return result.docs.map((doc) => ActivityLog.fromFirestore(doc)).toList();
  }

  Future<void> logActivity(ActivityLog activity) async {
    await _activityRef.add(activity.toFirestore());
  }

  Stream<List<ActivityLog>> watchActivity(String businessId, {int limit = 50}) {
    return _activityRef
        .where('businessId', isEqualTo: businessId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLog.fromFirestore(doc))
            .toList());
  }

  // ==================== Stamp Operations ====================

  /// Add stamp to customer and return updated progress
  Future<({CustomerProgress progress, bool rewardUnlocked})> addStamp({
    required String businessId,
    required String customerId,
    required String programId,
    required String programName,
    required int stampsRequired,
    required String customerPhone,
    String? customerName,
  }) async {
    // Get or create progress
    CustomerProgress? progress = await getProgress(customerId, programId);
    bool isNewProgress = progress == null;

    if (isNewProgress) {
      progress = CustomerProgress(
        id: '',
        customerId: customerId,
        programId: programId,
        businessId: businessId,
        stamps: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await createProgress(progress);
      progress = progress.copyWith(id: id);
    }

    // Calculate new stamp count
    int newStamps = progress.stamps + 1;
    bool rewardUnlocked = false;
    int rewardsRedeemed = progress.rewardsRedeemed;

    // Check if reward unlocked
    if (newStamps >= stampsRequired) {
      rewardUnlocked = true;
      rewardsRedeemed += 1;
      newStamps = 0; // Reset stamps after reward
    }

    // Update progress
    await updateProgress(progress.id, {
      'stamps': newStamps,
      'rewardsRedeemed': rewardsRedeemed,
      'lastStampAt': Timestamp.now(),
    });

    // Update customer
    await updateCustomer(customerId, {
      'totalVisits': FieldValue.increment(1),
      'lastVisit': Timestamp.now(),
      if (rewardUnlocked) 'totalRewards': FieldValue.increment(1),
    });

    // Update program stats
    await updateProgram(programId, {
      'totalStamps': FieldValue.increment(1),
      if (rewardUnlocked) 'totalRewards': FieldValue.increment(1),
      if (isNewProgress) 'totalCustomers': FieldValue.increment(1),
    });

    // Log activity
    await logActivity(ActivityLog(
      id: '',
      businessId: businessId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      programId: programId,
      programName: programName,
      type: rewardUnlocked ? ActivityType.reward : ActivityType.stamp,
      stampCount: rewardUnlocked ? stampsRequired : newStamps,
      maxStamps: stampsRequired,
      timestamp: DateTime.now(),
    ));

    return (
      progress: CustomerProgress(
        id: progress.id,
        customerId: customerId,
        programId: programId,
        businessId: businessId,
        stamps: newStamps,
        rewardsRedeemed: rewardsRedeemed,
        lastStampAt: DateTime.now(),
        createdAt: progress.createdAt,
        updatedAt: DateTime.now(),
      ),
      rewardUnlocked: rewardUnlocked,
    );
  }

  // ==================== Analytics ====================

  Future<Map<String, dynamic>> getAnalytics(
    String businessId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Query activity_log - using only businessId + timestamp desc to match existing index
      // Then filter date range client-side to avoid compound index issues
      final activity = await _activityRef
          .where('businessId', isEqualTo: businessId)
          .orderBy('timestamp', descending: true)
          .limit(500) // Limit for performance
          .get();

      int totalStamps = 0;
      int totalRewards = 0;
      int newCustomers = 0;

      final startTs = Timestamp.fromDate(startDate);
      final endTs = Timestamp.fromDate(endDate);

      for (final doc in activity.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        
        // Filter by date range client-side
        if (timestamp == null) continue;
        if (timestamp.compareTo(startTs) < 0) continue; // Before start
        if (timestamp.compareTo(endTs) > 0) continue; // After end
        
        final type = data['type'] as String?;
        if (type == 'stamp') {
          totalStamps++;
        } else if (type == 'reward') {
          totalRewards++;
        } else if (type == 'newCustomer' || type == 'new_customer') {
          newCustomers++;
        }
      }

      return {
        'totalStamps': totalStamps,
        'totalRewards': totalRewards,
        'newCustomers': newCustomers,
      };
    } catch (e) {
      // Log error and return zeros to prevent crash
      print('getAnalytics error: $e');
      return {
        'totalStamps': 0,
        'totalRewards': 0,
        'newCustomers': 0,
      };
    }
  }
}
