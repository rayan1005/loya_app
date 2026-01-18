import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/models/models.dart';

/// Public Join Program Screen
/// Customers access this via QR code or shared link
/// URL: /join?program=PROGRAM_ID
class JoinProgramScreen extends ConsumerStatefulWidget {
  final String? programId;

  const JoinProgramScreen({super.key, this.programId});

  @override
  ConsumerState<JoinProgramScreen> createState() => _JoinProgramScreenState();
}

class _JoinProgramScreenState extends ConsumerState<JoinProgramScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _fullPhoneNumber = '';
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _error;

  LoyaltyProgram? _program;
  Map<String, dynamic>? _businessData;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProgram() async {
    debugPrint('JoinProgramScreen: programId = ${widget.programId}');
    
    if (widget.programId == null || widget.programId!.isEmpty) {
      setState(() {
        _error = 'رابط غير صالح - لم يتم تحديد البرنامج';
        _isLoading = false;
      });
      return;
    }

    try {
      debugPrint('JoinProgramScreen: Fetching program ${widget.programId}');
      final programDoc = await FirebaseFirestore.instance
          .collection('programs')
          .doc(widget.programId)
          .get();

      debugPrint('JoinProgramScreen: Program exists = ${programDoc.exists}');
      
      if (!programDoc.exists) {
        setState(() {
          _error = 'البرنامج غير موجود\nID: ${widget.programId}';
          _isLoading = false;
        });
        return;
      }

      // Parse program data safely
      final data = programDoc.data() as Map<String, dynamic>?;
      if (data == null) {
        setState(() {
          _error = 'البرنامج غير موجود';
          _isLoading = false;
        });
        return;
      }
      
      // Extract only the fields we need to avoid type errors
      _program = LoyaltyProgram(
        id: programDoc.id,
        businessId: data['businessId']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        description: data['description']?.toString(),
        rewardDescription: data['rewardDescription']?.toString() ?? 
            data['reward_details']?.toString() ?? '',
        stampsRequired: (data['stampsRequired'] ?? data['stamps_required'] ?? 10) as int,
        isActive: data['isActive'] ?? true,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      // Load business info
      final businessDoc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(_program!.businessId)
          .get();

      if (businessDoc.exists) {
        _businessData = businessDoc.data();
      }

      setState(() => _isLoading = false);
    } catch (e, stackTrace) {
      debugPrint('Error loading program: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _error = 'حدث خطأ أثناء تحميل البرنامج';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinProgram() async {
    if (_fullPhoneNumber.isEmpty || _fullPhoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم هاتف صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final businessId = _program!.businessId;

      // Check if customer already exists
      final existingCustomer = await FirebaseFirestore.instance
          .collection('customers')
          .where('businessId', isEqualTo: businessId)
          .where('phone', isEqualTo: _fullPhoneNumber)
          .limit(1)
          .get();

      String customerId;

      if (existingCustomer.docs.isNotEmpty) {
        customerId = existingCustomer.docs.first.id;
      } else {
        // Create new customer
        final newCustomer = await FirebaseFirestore.instance
            .collection('customers')
            .add({
          'businessId': businessId,
          'phone': _fullPhoneNumber,
          'name': _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          'totalVisits': 0,
          'totalRewards': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'source': 'join_link',
        });
        customerId = newCustomer.id;
      }

      // Check if progress exists for this program
      final existingProgress = await FirebaseFirestore.instance
          .collection('customer_progress')
          .where('customerId', isEqualTo: customerId)
          .where('programId', isEqualTo: widget.programId)
          .limit(1)
          .get();

      if (existingProgress.docs.isEmpty) {
        // Create progress entry
        await FirebaseFirestore.instance.collection('customer_progress').add({
          'customerId': customerId,
          'programId': widget.programId,
          'businessId': businessId,
          'stamps': 0,
          'totalStamps': 0,
          'rewardsEarned': 0,
          'rewardsRedeemed': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : _isSuccess
                    ? _buildSuccessView()
                    : _buildJoinForm(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    final businessName = _businessData?['name'] ?? 'المتجر';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle,
                size: 60,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تم الانضمام بنجاح! 🎉',
              style: AppTypography.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'أنت الآن عضو في برنامج الولاء الخاص بـ $businessName',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _program?.name ?? '',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.gift, size: 32, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    'اجمع ${_program?.stampsRequired ?? 10} أختام',
                    style: AppTypography.titleMedium,
                  ),
                  Text(
                    'واحصل على مكافأة مجانية!',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinForm() {
    final businessName = _businessData?['name'] ?? 'المتجر';
    final businessLogo = _businessData?['logo'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Business Logo
              if (businessLogo != null && businessLogo.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    businessLogo,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultLogo(),
                  ),
                )
              else
                _buildDefaultLogo(),

              const SizedBox(height: 24),

              // Business Name
              Text(
                businessName,
                style: AppTypography.headline,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Program Name
              Text(
                _program?.name ?? 'برنامج الولاء',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Program Description
              if (_program?.description != null &&
                  _program!.description!.isNotEmpty)
                Text(
                  _program!.description!,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 32),

              // Join Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'انضم الآن',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل رقم هاتفك للانضمام لبرنامج الولاء',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field (optional)
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم (اختياري)',
                        prefixIcon: const Icon(LucideIcons.user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      initialCountryCode: 'SA',
                      onChanged: (phone) {
                        _fullPhoneNumber = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Join Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _joinProgram,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'انضم الآن',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reward Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.gift, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'اجمع ${_program?.stampsRequired ?? 10} أختام واحصل على مكافأة مجانية!',
                        style: AppTypography.body.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        LucideIcons.store,
        size: 50,
        color: Colors.white,
      ),
    );
  }
}
