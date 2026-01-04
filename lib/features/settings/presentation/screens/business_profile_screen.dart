import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/services/api_service.dart';
import '../../../shared/widgets/loya_button.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isUploading = false;
  bool _isInitialLoading = true;
  String? _logoUrl;
  String? _businessId;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) {
      setState(() => _isInitialLoading = false);
      return;
    }

    _businessId = businessId;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        // Set controller values without triggering hasChanges
        _businessNameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _addressController.text = data['address'] ?? '';
        _logoUrl = data['logoUrl'];
        
        // Now update the UI
        if (mounted) {
          setState(() {
            _isInitialLoading = false;
            _hasChanges = false; // Reset in case onChanged was triggered
          });
        }
      } else {
        if (mounted) {
          setState(() => _isInitialLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Failed to load business data: $e');
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            l10n.isRtl ? LucideIcons.arrowRight : LucideIcons.arrowLeft,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.get('business_profile'),
          style: AppTypography.headline,
        ),
        actions: [
          if (_hasChanges && !_isInitialLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: Text(
                  l10n.get('save'),
                  style: AppTypography.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              onChanged: () {
                if (!_hasChanges && !_isInitialLoading) {
                  setState(() => _hasChanges = true);
                }
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isMobile
                      ? AppSpacing.pagePaddingMobile
                      : AppSpacing.pagePadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo section
                        _buildLogoSection(l10n),
                        const SizedBox(height: 32),

                        // Business info section
                        _buildSectionTitle(l10n.get('business_info')),
                        const SizedBox(height: 16),
                        _buildInfoCard([
                          _buildTextField(
                            label: l10n.get('business_name'),
                            controller: _businessNameController,
                            icon: LucideIcons.building2,
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Contact info section
                        _buildSectionTitle(l10n.get('contact_info')),
                        const SizedBox(height: 16),
                        _buildInfoCard([
                          _buildPhoneField(l10n),
                          const Divider(height: 1),
                          _buildTextField(
                            label: l10n.get('email'),
                            controller: _emailController,
                            icon: LucideIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const Divider(height: 1),
                          _buildTextField(
                            label: l10n.get('address'),
                            controller: _addressController,
                            icon: LucideIcons.mapPin,
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Business ID section
                        _buildSectionTitle(l10n.get('business_id')),
                        const SizedBox(height: 16),
                        _buildIdCard(l10n),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _hasChanges && !_isInitialLoading
          ? Container(
              padding: EdgeInsets.all(
                isMobile
                    ? AppSpacing.pagePaddingMobile
                    : AppSpacing.pagePadding,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: LoyaButton(
                      label: l10n.get('save_changes'),
                      onPressed: _isLoading ? null : _saveProfile,
                      isLoading: _isLoading,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLogoSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          // Logo display
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadLogo,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                image: _logoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_logoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _isUploading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _logoUrl == null
                      ? const Icon(
                          LucideIcons.image,
                          size: 32,
                          color: AppColors.textTertiary,
                        )
                      : null,
            ),
          ),
          const SizedBox(width: 20),

          // Upload info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('business_logo'),
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.get('logo_requirements'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickAndUploadLogo,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.upload, size: 16),
                  label: Text(_isUploading
                      ? l10n.get('uploading')
                      : l10n.get('upload_logo')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final businessId = _businessId;
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('businesses')
          .child(businessId)
          .child('logo_${DateTime.now().millisecondsSinceEpoch}.png');

      UploadTask uploadTask;
      if (kIsWeb) {
        // Web: use putData
        final bytes = await pickedFile.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/png'),
        );
      } else {
        // Mobile: use putFile
        uploadTask = storageRef.putFile(
          File(pickedFile.path),
          SettableMetadata(contentType: 'image/png'),
        );
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .update({
        'logoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _logoUrl = downloadUrl;
        _isUploading = false;
        _hasChanges = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.get('logo_uploaded')),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Refresh all passes to update with new logo
        _refreshAllPasses(businessId);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _refreshAllPasses(String businessId) async {
    try {
      // Get all programs for this business
      final programsSnap = await FirebaseFirestore.instance
          .collection('programs')
          .where('businessId', isEqualTo: businessId)
          .get();
      
      if (programsSnap.docs.isEmpty) return;
      
      final programIds = programsSnap.docs.map((d) => d.id).toList();
      
      // Show refreshing notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جاري تحديث بطاقات العملاء بالشعار الجديد...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      final apiService = ApiService();
      final result = await apiService.refreshBusinessPasses(
        businessId: businessId,
        programIds: programIds,
      );
      
      if (mounted) {
        final updated = result['updated'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ تم تحديث $updated بطاقة بالشعار الجديد'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to refresh passes: $e');
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.label.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.phone,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('phone'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: IntlPhoneField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    initialCountryCode: 'SA',
                    disableLengthCheck: true,
                    showDropdownIcon: false,
                    flagsButtonMargin: EdgeInsets.zero,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdCard(AppLocalizations l10n) {
    final businessId = _businessId ?? 'Loading...';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.fingerprint,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('your_business_id'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  businessId,
                  style: AppTypography.mono.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: businessId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.get('copied_to_clipboard')),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(
              LucideIcons.copy,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_businessId == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(_businessId)
          .update({
        'name': _businessNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.get('profile_saved')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
