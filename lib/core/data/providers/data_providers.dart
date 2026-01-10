import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

/// Provider for Firestore service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provider for current user's phone number (from Firebase Auth)
final currentUserPhoneProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.phoneNumber;
});

/// Provider for current business ID
final currentBusinessIdProvider = StateProvider<String?>((ref) => null);

/// Provider for current business
final currentBusinessProvider = StreamProvider<Business?>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  if (businessId == null) return Stream.value(null);

  final service = ref.watch(firestoreServiceProvider);
  return service.watchBusiness(businessId);
});

/// Provider for programs list
final programsProvider = StreamProvider<List<LoyaltyProgram>>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  if (businessId == null) return Stream.value([]);

  final service = ref.watch(firestoreServiceProvider);
  return service.watchPrograms(businessId);
});

/// Provider for customers list
final customersProvider = StreamProvider<List<Customer>>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  if (businessId == null) return Stream.value([]);

  final service = ref.watch(firestoreServiceProvider);
  return service.watchCustomers(businessId);
});

/// Provider for activity feed
final activityProvider = StreamProvider<List<ActivityLog>>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  if (businessId == null) return Stream.value([]);

  final service = ref.watch(firestoreServiceProvider);
  return service.watchActivity(businessId);
});

/// Provider for dashboard stats
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final businessId = ref.watch(currentBusinessIdProvider);
  if (businessId == null) {
    return {
      'totalCustomers': 0,
      'activePrograms': 0,
      'stampsToday': 0,
      'rewardsIssued': 0,
    };
  }

  final service = ref.watch(firestoreServiceProvider);
  final programs = await service.getPrograms(businessId);
  final customers = await service.getCustomers(businessId);

  // Get today's activity
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final analytics = await service.getAnalytics(
    businessId,
    startDate: startOfDay,
    endDate: now,
  );

  return {
    'totalCustomers': customers.length,
    'activePrograms': programs.where((p) => p.isActive).length,
    'stampsToday': analytics['totalStamps'] ?? 0,
    'rewardsIssued': analytics['totalRewards'] ?? 0,
  };
});

/// Program notifier for CRUD operations
class ProgramNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _service;
  final String? _businessId;

  ProgramNotifier(this._service, this._businessId)
      : super(const AsyncValue.data(null));

  Future<String?> createProgram({
    required String name,
    String? description,
    required String rewardDescription,
    required int stampsRequired,
    String backgroundColor = '#007AFF',
    String foregroundColor = '#FFFFFF',
    String labelColor = '#FFFFFF',
    String stampStyle = 'circle',
    // Legacy parameters for backwards compatibility
    String? color,
    String? icon,
  }) async {
    if (_businessId == null) return null;

    state = const AsyncValue.loading();
    try {
      final program = LoyaltyProgram(
        id: '',
        businessId: _businessId,
        name: name,
        description: description,
        rewardDescription: rewardDescription,
        stampsRequired: stampsRequired,
        backgroundColor: color ?? backgroundColor,
        foregroundColor: foregroundColor,
        labelColor: labelColor,
        stampStyle: icon ?? stampStyle,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _service.createProgram(program);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateProgram(
      String programId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateProgram(programId, data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteProgram(String programId) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteProgram(programId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final programNotifierProvider =
    StateNotifierProvider<ProgramNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  return ProgramNotifier(service, businessId);
});

/// Customer notifier for CRUD operations
class CustomerNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _service;
  final String? _businessId;

  CustomerNotifier(this._service, this._businessId)
      : super(const AsyncValue.data(null));

  Future<String?> createCustomer({
    required String phone,
    String? name,
    String? notes,
  }) async {
    if (_businessId == null) return null;

    state = const AsyncValue.loading();
    try {
      // Check if customer already exists
      final existing = await _service.getCustomerByPhone(_businessId, phone);
      if (existing != null) {
        state = const AsyncValue.data(null);
        return existing.id;
      }

      final customer = Customer(
        id: '',
        businessId: _businessId,
        phone: phone,
        name: name,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _service.createCustomer(customer);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateCustomer(
      String customerId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateCustomer(customerId, data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<Customer?> findOrCreateCustomer(String phone, {String? name}) async {
    if (_businessId == null) return null;

    state = const AsyncValue.loading();
    try {
      // Try to find existing customer
      var customer = await _service.getCustomerByPhone(_businessId, phone);

      if (customer == null) {
        // Create new customer
        final id = await createCustomer(phone: phone, name: name);
        if (id != null) {
          customer = await _service.getCustomer(id);
        }
      }

      state = const AsyncValue.data(null);
      return customer;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final customerNotifierProvider =
    StateNotifierProvider<CustomerNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  return CustomerNotifier(service, businessId);
});

/// Stamp notifier for adding stamps
class StampNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _service;
  final String? _businessId;

  StampNotifier(this._service, this._businessId)
      : super(const AsyncValue.data(null));

  Future<({bool success, bool rewardUnlocked})?> addStamp({
    required String customerId,
    required String programId,
    required String programName,
    required int stampsRequired,
    required String customerPhone,
    String? customerName,
  }) async {
    if (_businessId == null) return null;

    state = const AsyncValue.loading();
    try {
      final result = await _service.addStamp(
        businessId: _businessId,
        customerId: customerId,
        programId: programId,
        programName: programName,
        stampsRequired: stampsRequired,
        customerPhone: customerPhone,
        customerName: customerName,
      );

      state = const AsyncValue.data(null);
      return (success: true, rewardUnlocked: result.rewardUnlocked);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final stampNotifierProvider =
    StateNotifierProvider<StampNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  return StampNotifier(service, businessId);
});

/// Provider for program customers count
final programCustomersCountProvider = FutureProvider.family<int, String>((ref, programId) async {
  final businessId = ref.watch(currentBusinessIdProvider);
  if (businessId == null) return 0;
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getProgramCustomersCount(businessId, programId);
});

/// Provider for program today stamps count
final programTodayStampsProvider = FutureProvider.family<int, String>((ref, programId) async {
  final businessId = ref.watch(currentBusinessIdProvider);
  if (businessId == null) return 0;
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getProgramTodayStamps(businessId, programId);
});
