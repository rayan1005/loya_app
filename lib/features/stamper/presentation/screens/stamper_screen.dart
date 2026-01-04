import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/utils/phone_utils.dart';

class StamperScreen extends ConsumerStatefulWidget {
  const StamperScreen({super.key});

  @override
  ConsumerState<StamperScreen> createState() => _StamperScreenState();
}

class _StamperScreenState extends ConsumerState<StamperScreen> {
  MobileScannerController? _scannerController;
  final bool _isScanning = false;
  String? _selectedProgramId;
  int _stampsToAdd = 1;

  // Manual entry
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  // Last scanned customer
  CustomerProgress? _lastScannedProgress;
  LoyaltyProgram? _lastScannedProgram;
  String? _lastScannedCustomerId;
  
  // Custom field controllers
  final _customField1Controller = TextEditingController();
  final _customField2Controller = TextEditingController();
  final _customField3Controller = TextEditingController();
  bool _customFieldsSaved = false;

  @override
  void dispose() {
    _scannerController?.dispose();
    _phoneController.dispose();
    _customField1Controller.dispose();
    _customField2Controller.dispose();
    _customField3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessId = ref.watch(currentBusinessIdProvider);
    final programsAsync = ref.watch(programsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(LucideIcons.stamp, size: 28, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('ختم البطاقات', style: AppTypography.headline),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'امسح رمز QR أو أدخل رقم الهاتف لإضافة ختم',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              if (isMobile) ...[
                // Mobile: stacked layout
                _buildMainArea(businessId, programsAsync),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: _buildRecentActivity(businessId),
                ),
              ] else
                // Desktop: side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Scanner or Manual Entry
                    Expanded(
                      flex: 2,
                      child: _buildMainArea(businessId, programsAsync),
                    ),
                    const SizedBox(width: 24),

                    // Right: Recent Activity
                    SizedBox(
                      height: 600,
                      width: 350,
                      child: _buildRecentActivity(businessId),
                    ),
                  ],
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainArea(
      String? businessId, AsyncValue<List<LoyaltyProgram>> programsAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Program Selector
          programsAsync.when(
              data: (programs) {
                if (_selectedProgramId == null && programs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() => _selectedProgramId = programs.first.id);
                  });
              }
              return DropdownButtonFormField<String>(
                initialValue: _selectedProgramId,
                decoration: InputDecoration(
                  labelText: 'البرنامج',
                  prefixIcon: const Icon(LucideIcons.gift),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: programs
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedProgramId = value),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('خطأ في تحميل البرامج'),
          ),
          const SizedBox(height: 24),

          // Stamps to Add
          Row(
            children: [
              Text('عدد الأختام: ', style: AppTypography.label),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _stampsToAdd > 1
                    ? () => setState(() => _stampsToAdd--)
                    : null,
                icon: const Icon(LucideIcons.minus),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Container(
                width: 60,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_stampsToAdd',
                  style: AppTypography.title.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _stampsToAdd < 10
                    ? () => setState(() => _stampsToAdd++)
                    : null,
                icon: const Icon(LucideIcons.plus),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Scanner Toggle - opens fullscreen scanner on mobile
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openFullscreenScanner(context, businessId),
                  icon: const Icon(LucideIcons.scanLine),
                  label: const Text('مسح QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Manual Entry (always shown)
          _buildManualEntry(businessId),

          // Last Scanned Result
          if (_lastScannedProgress != null) ...[
            const Divider(height: 32),
            _buildLastResult(),
          ],
        ],
      ),
    );
  }

  /// Opens a fullscreen scanner dialog
  Future<void> _openFullscreenScanner(
      BuildContext context, String? businessId) async {
    if (businessId == null || _selectedProgramId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار البرنامج أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullscreenScanner(
          onScanned: (code) {
            Navigator.of(context).pop(code);
          },
        ),
      ),
    );

    if (result != null && mounted) {
      // Process the scanned QR code
      await _processScannedCode(result, businessId);
    }
  }

  Future<void> _processScannedCode(String code, String businessId) async {
    setState(() => _isProcessing = true);

    try {
      // Try to parse as JSON (customer pass QR)
      Map<String, dynamic>? qrData;
      try {
        qrData = jsonDecode(code) as Map<String, dynamic>;
      } catch (_) {
        // Not JSON, might be a URL, phone number, or customer ID
      }

      String? customerId;
      String? phone;
      String? programId;

      if (qrData != null) {
        // JSON format from pass
        customerId = qrData['customerId'] as String?;
        phone = qrData['phone'] as String?;
        programId = qrData['programId'] as String?;
      } else if (code.startsWith('http://') || code.startsWith('https://')) {
        // URL format - extract parameters
        // QR format: https://loya.live/add-stamp?uid=XXX&program=YYY&serial=ZZZ
        try {
          final uri = Uri.parse(code);
          customerId = uri.queryParameters['uid'] ?? uri.queryParameters['customerId'];
          programId = uri.queryParameters['program'] ?? uri.queryParameters['pid'] ?? uri.queryParameters['programId'];
          phone = uri.queryParameters['phone'];
        } catch (_) {
          // Invalid URL
        }
      } else {
        // Treat as phone number
        phone = code;
      }

      bool success = false;
      
      // If we have a customerId from QR, verify it belongs to this business
      if (customerId != null) {
        // FIRST: Check if the program from QR belongs to this business
        if (programId != null) {
          final scannedProgramDoc = await FirebaseFirestore.instance
              .collection('programs')
              .doc(programId)
              .get();
          
          if (!scannedProgramDoc.exists) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('البرنامج غير موجود'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          
          final scannedProgramBusinessId = scannedProgramDoc.data()?['businessId'] as String?;
          if (scannedProgramBusinessId != businessId) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('هذه البطاقة تابعة لنشاط تجاري آخر'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
        
        // Check if this customer exists
        final customerDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .get();
        
        if (!customerDoc.exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('العميل غير موجود'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        final customerData = customerDoc.data()!;
        final customerBusinessId = customerData['businessId'] as String?;
        
        // Verify customer belongs to THIS business
        if (customerBusinessId != null && customerBusinessId != businessId) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('هذه البطاقة تابعة لنشاط تجاري آخر'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Use the selected program (since QR might not have programId)
        final targetProgramId = programId ?? _selectedProgramId;
        
        if (targetProgramId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى اختيار البرنامج'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Verify the program belongs to this business too
        final programDoc = await FirebaseFirestore.instance
            .collection('programs')
            .doc(targetProgramId)
            .get();
        
        if (!programDoc.exists || programDoc.data()?['businessId'] != businessId) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('البرنامج غير صالح'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        await _addStamp(businessId, customerId, targetProgramId);
        success = true;
        
      } else if (phone != null) {
        _phoneController.text = phone;
        success = await _addStampByPhone(businessId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رمز QR غير صالح'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الختم بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildScanner(String? businessId) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          MobileScanner(
            controller: _scannerController ??= MobileScannerController(),
            onDetect: (capture) => _handleScan(capture, businessId),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Text(
              'وجّه الكاميرا نحو رمز QR',
              style: AppTypography.body.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry(String? businessId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.smartphone, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 8),
        Text(
          'أو أدخل رقم الهاتف',
          style: AppTypography.body
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.center,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: '05xxxxxxxx',
            prefixIcon: const Icon(LucideIcons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                _isProcessing ? null : () => _addStampByPhone(businessId),
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(LucideIcons.stamp),
            label: Text(_isProcessing ? 'جاري الختم...' : 'إضافة ختم'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastResult() {
    if (_lastScannedProgress == null || _lastScannedProgram == null) {
      return const SizedBox();
    }

    final progress = _lastScannedProgress!;
    final program = _lastScannedProgram!;
    final isComplete = progress.stamps >= program.stampsRequired;
    final passFieldConfig = program.passFieldConfig;
    final hasCustomFields = passFieldConfig.showCustomField1 || 
        passFieldConfig.showCustomField2 || 
        passFieldConfig.showCustomField3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // === STAMP PROGRESS SECTION ===
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.success.withOpacity(0.15)
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Status header
              Row(
                children: [
                  Icon(
                    isComplete ? LucideIcons.gift : LucideIcons.checkCircle,
                    color: isComplete ? AppColors.success : AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isComplete ? '🎉 مكافأة مستحقة!' : '✓ تم إضافة الختم',
                          style: AppTypography.titleMedium.copyWith(
                            color: isComplete ? AppColors.success : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${progress.stamps} / ${program.stampsRequired} ختم',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stamp visualization - on the right
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(
                      program.stampsRequired,
                      (i) => Icon(
                        i < progress.stamps
                            ? LucideIcons.circleDot
                            : LucideIcons.circle,
                        size: program.stampsRequired > 10 ? 12 : 16,
                        color: i < progress.stamps
                            ? (isComplete ? AppColors.success : AppColors.primary)
                            : AppColors.textTertiary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // === CUSTOM FIELDS SECTION ===
        if (hasCustomFields && !_customFieldsSaved) ...[
          const SizedBox(height: 16),
          // Custom fields directly (no extra card)
          if (passFieldConfig.showCustomField1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _customField1Controller,
                decoration: InputDecoration(
                  labelText: passFieldConfig.customField1Label?.isNotEmpty == true 
                      ? passFieldConfig.customField1Label 
                      : 'حقل 1',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          if (passFieldConfig.showCustomField2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _customField2Controller,
                decoration: InputDecoration(
                  labelText: passFieldConfig.customField2Label?.isNotEmpty == true 
                      ? passFieldConfig.customField2Label 
                      : 'حقل 2',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          if (passFieldConfig.showCustomField3)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _customField3Controller,
                decoration: InputDecoration(
                  labelText: passFieldConfig.customField3Label?.isNotEmpty == true 
                      ? passFieldConfig.customField3Label 
                      : 'حقل 3',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          FilledButton.icon(
            onPressed: _isProcessing ? null : _saveCustomFields,
            icon: _isProcessing 
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(LucideIcons.save, size: 16),
            label: Text(_isProcessing ? 'جاري الحفظ...' : 'حفظ'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Future<void> _saveCustomFields() async {
    if (_lastScannedCustomerId == null || _lastScannedProgram == null) return;
    
    final customerId = _lastScannedCustomerId!;
    final programId = _lastScannedProgram!.id;
    final passFieldConfig = _lastScannedProgram!.passFieldConfig;
    
    setState(() => _isProcessing = true);
    
    try {
      // Save to customer_progress
      final db = FirebaseFirestore.instance;
      final progressQuery = await db
          .collection('customer_progress')
          .where('customerId', isEqualTo: customerId)
          .where('programId', isEqualTo: programId)
          .limit(1)
          .get();
      
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (passFieldConfig.showCustomField1) {
        updateData['customField1'] = _customField1Controller.text.trim();
      }
      if (passFieldConfig.showCustomField2) {
        updateData['customField2'] = _customField2Controller.text.trim();
      }
      if (passFieldConfig.showCustomField3) {
        updateData['customField3'] = _customField3Controller.text.trim();
      }
      
      if (progressQuery.docs.isNotEmpty) {
        await progressQuery.docs.first.reference.update(updateData);
      } else {
        // Create new customer_progress document if it doesn't exist
        final businessId = ref.read(currentBusinessIdProvider);
        await db.collection('customer_progress').add({
          'customerId': customerId,
          'programId': programId,
          'businessId': businessId,
          'stamps': _lastScannedProgress?.stamps ?? 0,
          'rewardsRedeemed': _lastScannedProgress?.rewardsRedeemed ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
          ...updateData,
        });
      }
      
      // Update wallet pass via API
      try {
        final user = FirebaseAuth.instance.currentUser;
        final idToken = await user?.getIdToken();
        
        await http.post(
          Uri.parse('https://api-v4xex7aj3a-uc.a.run.app/api/updateCustomFields'),
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'user_id': customerId,
            'program_id': programId,
            'customField1': _customField1Controller.text.trim(),
            'customField2': _customField2Controller.text.trim(),
            'customField3': _customField3Controller.text.trim(),
          }),
        );
      } catch (e) {
        debugPrint('[Stamper] Failed to update custom fields via API: $e');
      }
      
      setState(() {
        _customFieldsSaved = true;
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم حفظ البيانات'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildRecentActivity(String? businessId) {
    if (businessId == null) {
      return const Center(child: Text('يرجى تسجيل الدخول'));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.history, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('النشاط الأخير', style: AppTypography.title),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activity_log')
                  .where('businessId', isEqualTo: businessId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Show error details for debugging
                  debugPrint('Activity stream error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.alertCircle,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text(
                          'خطأ في تحميل البيانات',
                          style: AppTypography.body
                              .copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'جاري إنشاء الفهرس...',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter for stamp type client-side
                final stampDocs = snapshot.data?.docs
                        .where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['type'] == 'stamp';
                        })
                        .take(10)
                        .toList() ??
                    [];

                if (!snapshot.hasData || stampDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.inbox,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          'لا يوجد نشاط',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: stampDocs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = stampDocs[index];
                    final log = ActivityLog.fromFirestore(doc);
                    return _buildActivityItem(log);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityLog log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child:
                  Icon(LucideIcons.stamp, size: 20, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.customerName ?? log.customerPhone,
                  style: AppTypography.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${log.stampCount ?? 1} ختم - ${log.programName}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(log.timestamp),
            style:
                AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes}د';
    if (diff.inHours < 24) return '${diff.inHours}س';
    return '${diff.inDays}ي';
  }

  void _handleScan(BarcodeCapture capture, String? businessId) async {
    if (_isProcessing || businessId == null || _selectedProgramId == null) {
      return;
    }

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _isProcessing = true);
    _scannerController?.stop();

    try {
      final data = jsonDecode(barcode!.rawValue!);
      final customerId = data['c'] as String?;
      final programId = data['p'] as String?;

      if (customerId == null) throw Exception('رمز غير صالح');

      await _addStamp(businessId, customerId, programId ?? _selectedProgramId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _scannerController?.start();
      }
    }
  }

  Future<bool> _addStampByPhone(String? businessId) async {
    if (businessId == null || _selectedProgramId == null) return false;

    final phoneInput = _phoneController.text.trim();
    if (phoneInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال رقم الهاتف'),
            backgroundColor: Colors.red),
      );
      return false;
    }

    // Normalize the phone number to consistent format
    final normalizedPhone = PhoneUtils.normalize(phoneInput);
    if (normalizedPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('رقم الهاتف غير صحيح'), backgroundColor: Colors.red),
      );
      return false;
    }

    setState(() => _isProcessing = true);

    try {
      // Search for existing customer with all possible phone variants
      final phoneVariants = PhoneUtils.getSearchVariants(phoneInput);
      QuerySnapshot<Map<String, dynamic>>? customerQuery;

      // First, search within this business's customers
      for (final phoneVar in phoneVariants) {
        customerQuery = await FirebaseFirestore.instance
            .collection('customers')
            .where('businessId', isEqualTo: businessId)
            .where('phone', isEqualTo: phoneVar)
            .limit(1)
            .get();
        if (customerQuery.docs.isNotEmpty) break;
      }

      // If not found, search globally (for legacy customers without businessId)
      if (customerQuery == null || customerQuery.docs.isEmpty) {
        for (final phoneVar in phoneVariants) {
          customerQuery = await FirebaseFirestore.instance
              .collection('customers')
              .where('phone', isEqualTo: phoneVar)
              .limit(1)
              .get();
          if (customerQuery.docs.isNotEmpty) break;
        }
      }

      if (customerQuery == null || customerQuery.docs.isEmpty) {
        // Create new customer with NORMALIZED phone
        final newCustomerRef =
            await FirebaseFirestore.instance.collection('customers').add({
          'businessId': businessId,
          'phone': normalizedPhone, // Always store normalized format
          'name': null,
          'totalVisits': 0,
          'totalRewards': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _addStamp(businessId, newCustomerRef.id, _selectedProgramId!, phone: normalizedPhone);
        _phoneController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تم إضافة عميل جديد وختمه'),
                backgroundColor: AppColors.success),
          );
        }
        return true;
      }

      // Update customer's businessId if missing
      final customerDoc = customerQuery.docs.first;
      final customerData = customerDoc.data();
      if (customerData['businessId'] == null) {
        await customerDoc.reference.update({'businessId': businessId});
      }

      // Use firebaseUid if available (for customers who joined via join page)
      // Otherwise use the document ID
      final customerId = customerData['firebaseUid'] as String? ?? 
                         customerData['uid'] as String? ?? 
                         customerDoc.id;
      final customerPhone = customerData['phone'] as String?;

      await _addStamp(businessId, customerId, _selectedProgramId!, phone: customerPhone);
      _phoneController.clear();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _addStamp(
      String businessId, String customerId, String programId, {String? phone}) async {
    final db = FirebaseFirestore.instance;

    // Get program
    final programDoc = await db.collection('programs').doc(programId).get();
    if (!programDoc.exists) throw Exception('البرنامج غير موجود');
    final program = LoyaltyProgram.fromFirestore(programDoc);

    // Check if customer has a wallet pass
    final walletPassQuery = await db
        .collection('wallet_passes')
        .where('user_id', isEqualTo: customerId)
        .where('program_id', isEqualTo: programId)
        .limit(1)
        .get();

    // Get customer info - try to find by customerId first, if not found try by phone
    var customerDoc = await db.collection('customers').doc(customerId).get();
    Map<String, dynamic>? customerData = customerDoc.data();
    
    // If customer not found by ID and we have phone, search by phone
    if (customerData == null && phone != null) {
      final phoneVariants = PhoneUtils.getSearchVariants(phone);
      for (final phoneVar in phoneVariants) {
        final phoneQuery = await db
            .collection('customers')
            .where('phone', isEqualTo: phoneVar)
            .limit(1)
            .get();
        if (phoneQuery.docs.isNotEmpty) {
          customerData = phoneQuery.docs.first.data();
          break;
        }
      }
    }
    
    // Get phone from customer data if not provided
    final customerPhone = phone ?? customerData?['phone'] as String?;

    // Call backend API to add stamps - let backend handle ALL the logic
    debugPrint(
        '[Stamper] Calling updateStamps API with stamps_to_add=$_stampsToAdd, hasWalletPass=${walletPassQuery.docs.isNotEmpty}, phone=$customerPhone');

    int newStamps = 0;
    int newRewards = 0;
    bool success = false;

    // Always call the API - it will handle both wallet pass update and customer_progress
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      final response = await http.post(
        Uri.parse('https://api-v4xex7aj3a-uc.a.run.app/api/updateStamps'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'user_id': customerId,
          'program_id': programId,
          'stamps_to_add': _stampsToAdd,
          if (customerPhone != null) 'phone': customerPhone,
        }),
      );

      debugPrint(
          '[Stamper] API response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        newStamps = data['stamps'] ?? 0;
        newRewards = data['rewards'] ?? 0;
        success = true;
      }
    } catch (e) {
      debugPrint('[Stamper] Failed to call API: $e');
    }

    // Don't update customer_progress here - backend already handles it
    // Just use API response values for UI display
    // Only create a new progress record if API failed and none exists
    if (!success) {
      final progressQuery = await db
          .collection('customer_progress')
          .where('customerId', isEqualTo: customerId)
          .where('programId', isEqualTo: programId)
          .limit(1)
          .get();

      if (progressQuery.docs.isEmpty) {
        // Create new progress only if API failed and no record exists
        final progressRef = db.collection('customer_progress').doc();
        await progressRef.set({
          'customerId': customerId,
          'programId': programId,
          'businessId': businessId,
          'stamps': _stampsToAdd,
          'rewardsRedeemed': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      } else {
        // API failed - update locally with increment
        await progressQuery.docs.first.reference.update({
          'stamps': FieldValue.increment(_stampsToAdd),
          'updatedAt': Timestamp.now(),
        });
      }
    }

    // Log activity
    await db.collection('activity_log').add({
      'businessId': businessId,
      'customerId': customerId,
      'customerName': customerData?['name'],
      'customerPhone': customerData?['phone'] ?? '',
      'programId': programId,
      'programName': program.name,
      'type': 'stamp',
      'stampCount': _stampsToAdd,
      'maxStamps': program.stampsRequired,
      'timestamp': Timestamp.now(),
    });

    // Update program stats
    await db.collection('programs').doc(programId).update({
      'totalStamps': FieldValue.increment(_stampsToAdd),
    });

    // Update customer totalVisits
    await db.collection('customers').doc(customerId).update({
      'totalVisits': FieldValue.increment(1),
    });

    // Update UI state - re-fetch progress for display
    final uiProgressQuery = await db
        .collection('customer_progress')
        .where('customerId', isEqualTo: customerId)
        .where('programId', isEqualTo: programId)
        .limit(1)
        .get();

    CustomerProgress? progress;
    if (uiProgressQuery.docs.isNotEmpty) {
      progress = CustomerProgress.fromFirestore(uiProgressQuery.docs.first);
    } else {
      // Create a temporary progress object for UI display even if not in database yet
      // This ensures custom fields form appears for new customers
      progress = CustomerProgress(
        id: '',
        customerId: customerId,
        programId: programId,
        businessId: businessId,
        stamps: newStamps > 0 ? newStamps : _stampsToAdd,
        rewardsRedeemed: newRewards,
        customField1: '',
        customField2: '',
        customField3: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    setState(() {
      _lastScannedProgress = progress;
      _lastScannedProgram = program;
      _lastScannedCustomerId = customerId;
      // Reset custom fields for new scan
      _customFieldsSaved = false;
      _customField1Controller.text = progress?.customField1 ?? '';
      _customField2Controller.text = progress?.customField2 ?? '';
      _customField3Controller.text = progress?.customField3 ?? '';
    });

    // Show success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ تم إضافة $_stampsToAdd ختم'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

/// Fullscreen scanner widget for better mobile experience
class _FullscreenScanner extends StatefulWidget {
  final Function(String) onScanned;

  const _FullscreenScanner({required this.onScanned});

  @override
  State<_FullscreenScanner> createState() => _FullscreenScannerState();
}

class _FullscreenScannerState extends State<_FullscreenScanner> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _hasScanned = true;
      widget.onScanned(barcode!.rawValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('مسح رمز QR'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off),
            onPressed: () => _controller?.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scan overlay
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'وجّه الكاميرا نحو رمز QR الخاص بالعميل',
              style: AppTypography.body.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
