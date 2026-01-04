import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'data_providers.dart';

/// Provider for the current user context (owner or team member)
final userContextProvider = StateProvider<UserContext?>((ref) => null);

/// This provider initializes the business after user login
/// It either fetches the existing business, finds team membership, or creates a new one
final businessInitProvider = FutureProvider.autoDispose<Business?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final service = ref.watch(firestoreServiceProvider);
  final phone = user.phoneNumber ?? '';

  // Step 1: Try to find existing business by owner ID (user's UID)
  Business? business = await service.getBusinessByOwner(user.uid);

  if (business != null) {
    // User is a business owner
    ref.read(currentBusinessIdProvider.notifier).state = business.id;
    ref.read(userContextProvider.notifier).state = UserContext(
      type: 'owner',
      businessId: business.id,
      role: UserRole.owner,
      phone: phone,
    );
    return business;
  }

  // Step 2: Check if user is a team member of any business
  if (phone.isNotEmpty) {
    final teamMemberResult = await service.findTeamMemberByPhone(phone);
    
    if (teamMemberResult != null) {
      final businessId = teamMemberResult.businessId;
      final teamMember = teamMemberResult.member;
      
      // Fetch the business
      business = await service.getBusiness(businessId);
      
      if (business != null) {
        ref.read(currentBusinessIdProvider.notifier).state = business.id;
        ref.read(userContextProvider.notifier).state = UserContext(
          type: 'team_member',
          businessId: business.id,
          role: teamMember.userRole,
          teamMemberId: teamMember.id,
          name: teamMember.name,
          phone: teamMember.phone,
        );
        return business;
      }
    }
  }

  // Step 3: No business found and not a team member - create new business
  final newBusiness = Business(
    id: '',
    ownerId: user.uid,
    nameAr: 'نشاطي التجاري', // Default Arabic name
    nameEn: 'My Business', // Default English name
    phone: phone,
    email: '',
    plan: 'free',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final businessId = await service.createBusiness(newBusiness);
  business = newBusiness.copyWith(id: businessId);

  // Update the providers
  ref.read(currentBusinessIdProvider.notifier).state = business.id;
  ref.read(userContextProvider.notifier).state = UserContext(
    type: 'owner',
    businessId: business.id,
    role: UserRole.owner,
    phone: phone,
  );

  return business;
});
