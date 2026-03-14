import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/services/api_service.dart';
import '../../../../core/widgets/upgrade_dialog.dart';
import '../../../shared/widgets/upgrade_prompt.dart';

class LocationEngagementScreen extends ConsumerStatefulWidget {
  const LocationEngagementScreen({super.key});

  @override
  ConsumerState<LocationEngagementScreen> createState() =>
      _LocationEngagementScreenState();
}

class _LocationEngagementScreenState
    extends ConsumerState<LocationEngagementScreen> {
  bool _isEnabled = false;
  bool _isTimeBased = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Single message
  final _singleMessageController = TextEditingController();

  // Time slots (up to 4)
  List<_TimeSlot> _timeSlots = [
    _TimeSlot(startHour: 6, endHour: 12, message: ''),
    _TimeSlot(startHour: 12, endHour: 17, message: ''),
    _TimeSlot(startHour: 17, endHour: 24, message: ''),
  ];

  int _locationCount = 0;
  int _totalLocationCount = 0;

  // Program-location mapping
  List<Map<String, dynamic>> _programs = [];
  List<Map<String, dynamic>> _locations = [];
  // programId -> list of locationIds
  Map<String, List<String>> _programLocations = {};

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _singleMessageController.dispose();
    for (final slot in _timeSlots) {
      slot.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) return;

    try {
      // Load engagement config
      final doc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .collection('location_engagement')
          .doc('config')
          .get();

      // Load all locations
      final locSnap = await FirebaseFirestore.instance
          .collection('locations')
          .where('businessId', isEqualTo: businessId)
          .get();

      final allLocations = locSnap.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'name': data['name'] ?? '',
          'address': data['address'] ?? '',
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'isActive': data['isActive'] ?? true,
        };
      }).toList();

      final activeDocs = allLocations.where((l) => l['isActive'] == true).toList();
      final withGps = activeDocs.where((l) => l['latitude'] != null && l['longitude'] != null).toList();

      // Load all active programs
      final progSnap = await FirebaseFirestore.instance
          .collection('programs')
          .where('businessId', isEqualTo: businessId)
          .where('isActive', isEqualTo: true)
          .get();

      final programs = progSnap.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'name': data['name'] ?? data['programName'] ?? '',
        };
      }).toList();

      // Load saved mapping
      Map<String, List<String>> mapping = {};

      if (doc.exists) {
        final data = doc.data()!;
        _isEnabled = data['isEnabled'] ?? false;
        _isTimeBased = data['isTimeBased'] ?? false;
        _singleMessageController.text = data['defaultMessage'] ?? '';

        final slots = data['timeSlots'] as List<dynamic>? ?? [];
        if (slots.isNotEmpty) {
          _timeSlots = slots.map((s) {
            final slot = _TimeSlot(
              startHour: s['startHour'] ?? 0,
              endHour: s['endHour'] ?? 24,
              message: s['message'] ?? '',
            );
            slot.controller.text = s['message'] ?? '';
            return slot;
          }).toList();
        }

        // Load program-location mapping
        final savedMapping = data['programLocations'] as Map<String, dynamic>? ?? {};
        for (final entry in savedMapping.entries) {
          mapping[entry.key] = List<String>.from(entry.value ?? []);
        }
      }

      // Default: if no mapping saved, all locations for all programs
      if (mapping.isEmpty && programs.isNotEmpty && withGps.isNotEmpty) {
        final allLocationIds = withGps.map((l) => l['id'] as String).toList();
        for (final prog in programs) {
          mapping[prog['id'] as String] = List<String>.from(allLocationIds);
        }
      }

      setState(() {
        _totalLocationCount = activeDocs.length;
        _locationCount = withGps.length;
        _locations = withGps;
        _programs = programs;
        _programLocations = mapping;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('[LocationEngagement] Load error: $e');
    }
  }

  Future<void> _saveConfig() async {
    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) return;

    setState(() => _isSaving = true);
    try {
      // Sync message text from controllers
      for (final slot in _timeSlots) {
        slot.message = slot.controller.text.trim();
      }

      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .collection('location_engagement')
          .doc('config')
          .set({
        'isEnabled': _isEnabled,
        'isTimeBased': _isTimeBased,
        'defaultMessage': _singleMessageController.text.trim(),
        'timeSlots': _timeSlots
            .map((s) => {
                  'startHour': s.startHour,
                  'endHour': s.endHour,
                  'message': s.message,
                })
            .toList(),
        'programLocations': _programLocations,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Trigger pass refresh for all programs
      await _refreshAllPasses(businessId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _refreshAllPasses(String businessId) async {
    try {
      final programsQuery = await FirebaseFirestore.instance
          .collection('programs')
          .where('businessId', isEqualTo: businessId)
          .where('isActive', isEqualTo: true)
          .get();

      if (programsQuery.docs.isEmpty) return;

      final apiService = ApiService();
      for (final doc in programsQuery.docs) {
        try {
          await apiService.refreshProgramPasses(programId: doc.id);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[LocationEngagement] Refresh error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final userPhone = ref.watch(currentUserPhoneProvider);
    final currentPlan = business?.plan ?? 'free';
    final hasAccess = AppConfig.businessHasFeature(
        currentPlan, userPhone, PlanFeature.locationPush);
    final hasTimeBased = AppConfig.businessHasFeature(
        currentPlan, userPhone, PlanFeature.timeBasedLocationMessages);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasAccess
              ? Center(
                  child: UpgradePrompt(
                    feature: PlanFeature.locationPush,
                    currentPlan: currentPlan,
                    isFullScreen: true,
                  ),
                )
              : _buildContent(hasTimeBased),
    );
  }

  Widget _buildContent(bool hasTimeBased) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 28, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التفاعل بالموقع',
                        style: AppTypography.title),
                    Text(
                      'إشعار العملاء عند اقترابهم من فروعك',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Location count info
          if (_totalLocationCount == 0) ...[
            _buildWarningBanner(
              'لا توجد فروع مضافة',
              'أضف فروعك من الإعدادات ← الفروع.',
              LucideIcons.alertTriangle,
              Colors.orange,
            ),
            const SizedBox(height: 16),
          ] else if (_locationCount == 0) ...[
            _buildWarningBanner(
              'فروعك بدون إحداثيات GPS',
              'عدّل فروعك من الإعدادات ← الفروع وأضف إحداثيات GPS لتفعيل الإشعارات.',
              LucideIcons.alertTriangle,
              Colors.orange,
            ),
            const SizedBox(height: 16),
          ] else ...[
            _buildInfoBanner(
              '$_locationCount فرع نشط',
              'الرسالة ستظهر عند اقتراب العميل من أي فرع.',
              LucideIcons.mapPin,
            ),
            const SizedBox(height: 16),
          ],

          // Enable toggle card
          _buildCard([
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تفعيل التنبيه بالموقع',
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'رسالة تظهر على شاشة القفل عند الاقتراب',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isEnabled,
                  onChanged: (v) => setState(() => _isEnabled = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 16),

          if (_isEnabled) ...[
            // Message mode selector
            _buildCard([
              Text('نوع الرسالة',
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildModeOption(
                icon: LucideIcons.messageSquare,
                title: 'رسالة واحدة',
                subtitle: 'نفس الرسالة في جميع الأوقات',
                isSelected: !_isTimeBased,
                onTap: () => setState(() => _isTimeBased = false),
              ),
              const SizedBox(height: 8),
              _buildModeOption(
                icon: LucideIcons.clock,
                title: 'رسائل حسب الوقت',
                subtitle: 'رسالة مختلفة لكل فترة (صباح، ظهر، مساء)',
                isSelected: _isTimeBased,
                isLocked: !hasTimeBased,
                onTap: () {
                  if (hasTimeBased) {
                    setState(() => _isTimeBased = true);
                  } else {
                    final business =
                        ref.read(currentBusinessProvider).valueOrNull;
                    showUpgradeDialog(
                      context,
                      feature: PlanFeature.timeBasedLocationMessages,
                      currentPlan: business?.plan ?? 'free',
                    );
                  }
                },
              ),
            ]),
            const SizedBox(height: 16),

            // === SINGLE MESSAGE ===
            if (!_isTimeBased) ...[
              _buildCard([
                Row(
                  children: [
                    Icon(LucideIcons.messageSquare,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('رسالة الاقتراب',
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _singleMessageController,
                  textDirection: TextDirection.rtl,
                  maxLength: 100,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'مثال: مرحباً! اعرض بطاقتك واحصل على ختمك 🎉',
                    hintStyle: AppTypography.caption
                        .copyWith(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تظهر على شاشة القفل عند اقتراب العميل من الفرع',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ]),
            ],

            // === TIME-BASED MESSAGES ===
            if (_isTimeBased) ...[
              _buildCard([
                Row(
                  children: [
                    Icon(LucideIcons.clock,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('الفترات الزمنية',
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'يتم تحديث البطاقة تلقائياً حسب الفترة الحالية',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),
                ..._timeSlots.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final slot = entry.value;
                  return _buildTimeSlotEditor(slot, idx);
                }),
                const SizedBox(height: 12),
                if (_timeSlots.length < 4)
                  TextButton.icon(
                    onPressed: _addTimeSlot,
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('إضافة فترة'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ]),
            ],
            const SizedBox(height: 16),

            // Preview card
            _buildCard([
              Row(
                children: [
                  Icon(LucideIcons.eye, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('معاينة',
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              _buildPreview(),
            ]),
            const SizedBox(height: 16),

            // Program-Location mapping
            if (_programs.length > 1 && _locations.isNotEmpty) ...[
              _buildProgramLocationMapping(),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('حفظ الإعدادات',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildProgramLocationMapping() {
    return _buildCard([
      Row(
        children: [
          Icon(LucideIcons.link, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ربط الفروع بالبرامج',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'حدد أي فرع يتبع أي برنامج ولاء',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ..._programs.map((prog) {
        final progId = prog['id'] as String;
        final progName = prog['name'] as String;
        final assignedIds = _programLocations[progId] ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.creditCard,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(progName,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    '${assignedIds.length}/${_locations.length}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._locations.map((loc) {
                final locId = loc['id'] as String;
                final locName = loc['name'] as String;
                final isChecked = assignedIds.contains(locId);

                return InkWell(
                  onTap: () {
                    setState(() {
                      final list =
                          _programLocations[progId] ?? [];
                      if (isChecked) {
                        list.remove(locId);
                      } else {
                        list.add(locId);
                      }
                      _programLocations[progId] = list;
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          isChecked
                              ? LucideIcons.checkSquare
                              : LucideIcons.square,
                          size: 20,
                          color: isChecked
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.mapPin,
                            size: 16,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(locName,
                              style: AppTypography.body.copyWith(
                                  color: isChecked
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    ]);
  }

  Widget _buildTimeSlotEditor(_TimeSlot slot, int index) {
    final timeLabels = ['🌅', '☀️', '🌆', '🌙'];
    final periodNames = [
      _getPeriodName(slot.startHour, slot.endHour),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                timeLabels[index % timeLabels.length],
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  periodNames[0],
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (_timeSlots.length > 1)
                IconButton(
                  icon: Icon(LucideIcons.trash2,
                      size: 18, color: Colors.red.shade400),
                  onPressed: () => _removeTimeSlot(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Time pickers
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  label: 'من',
                  value: slot.startHour,
                  onChanged: (v) =>
                      setState(() => _timeSlots[index].startHour = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePicker(
                  label: 'إلى',
                  value: slot.endHour,
                  onChanged: (v) =>
                      setState(() => _timeSlots[index].endHour = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Message
          TextField(
            controller: slot.controller,
            textDirection: TextDirection.rtl,
            maxLength: 100,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'رسالة هذه الفترة...',
              hintStyle: AppTypography.caption
                  .copyWith(color: AppColors.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTypography.caption.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              items: List.generate(25, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(
                    i == 0
                        ? '12:00 ص'
                        : i == 12
                            ? '12:00 م'
                            : i == 24
                                ? '12:00 ص (اليوم التالي)'
                                : i < 12
                                    ? '${i}:00 ص'
                                    : '${i - 12}:00 م',
                    style: AppTypography.body,
                  ),
                );
              }),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getPeriodName(int start, int end) {
    if (start >= 5 && end <= 12) return 'الفترة الصباحية';
    if (start >= 12 && end <= 17) return 'فترة الظهر';
    if (start >= 17 && end <= 21) return 'فترة المساء';
    if (start >= 21 || end <= 5) return 'الفترة الليلية';
    final startStr = start == 0
        ? '12ص'
        : start == 12
            ? '12م'
            : start < 12
                ? '${start}ص'
                : '${start - 12}م';
    final endStr = end == 0 || end == 24
        ? '12ص'
        : end == 12
            ? '12م'
            : end < 12
                ? '${end}ص'
                : '${end - 12}م';
    return '$startStr – $endStr';
  }

  Widget _buildPreview() {
    String currentMessage;
    if (_isTimeBased) {
      final now = DateTime.now().hour;
      final activeSlot = _timeSlots.where(
          (s) => now >= s.startHour && now < s.endHour);
      if (activeSlot.isNotEmpty) {
        currentMessage = activeSlot.first.controller.text.trim();
      } else {
        currentMessage = '(لا توجد فترة نشطة الآن)';
      }
    } else {
      currentMessage = _singleMessageController.text.trim();
    }

    if (currentMessage.isEmpty) {
      currentMessage = 'رسالة الاقتراب ستظهر هنا...';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.creditCard,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بطاقة الولاء',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentMessage,
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addTimeSlot() {
    if (_timeSlots.length >= 4) return;
    final lastEnd =
        _timeSlots.isNotEmpty ? _timeSlots.last.endHour : 0;
    setState(() {
      _timeSlots.add(_TimeSlot(
        startHour: lastEnd,
        endHour: (lastEnd + 6).clamp(0, 24),
        message: '',
      ));
    });
  }

  void _removeTimeSlot(int index) {
    if (_timeSlots.length <= 1) return;
    setState(() {
      _timeSlots[index].controller.dispose();
      _timeSlots.removeAt(index);
    });
  }

  // === UI HELPERS ===

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary)),
                      if (isLocked) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Growth+',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.checkCircle2,
                  size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.body.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: AppTypography.caption
                        .copyWith(color: Colors.blue.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.body.copyWith(
                        color: color.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: AppTypography.caption
                        .copyWith(color: color.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSlot {
  int startHour;
  int endHour;
  String message;
  final TextEditingController controller;

  _TimeSlot({
    required this.startHour,
    required this.endHour,
    required this.message,
  }) : controller = TextEditingController(text: message);
}
