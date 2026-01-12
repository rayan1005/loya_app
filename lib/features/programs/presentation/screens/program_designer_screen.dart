import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/services/api_service.dart';
import '../../../shared/widgets/loya_button.dart';
import '../widgets/pass_preview_widget.dart';

class ProgramDesignerScreen extends ConsumerStatefulWidget {
  final String? programId; // null = create new, non-null = edit existing

  const ProgramDesignerScreen({super.key, this.programId});

  @override
  ConsumerState<ProgramDesignerScreen> createState() =>
      _ProgramDesignerScreenState();
}

class _ProgramDesignerScreenState extends ConsumerState<ProgramDesignerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  // === BASIC INFO ===
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController();
  int _stampsRequired = 8;

  // === DESIGN ===
  Color _backgroundColor = const Color(0xFF007AFF);
  Color _foregroundColor = Colors.white;
  Color _labelColor = Colors.white;
  Color _accentColor = const Color(0xFF007AFF);

  String? _logoUrl;
  String? _iconUrl;
  String? _stripUrl;
  String? _stampActiveUrl;
  String? _stampInactiveUrl;
  String _stampStyle = 'circle';

  // === CONTENT ===
  final _termsController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // === LOCATION ===
  double? _latitude;
  double? _longitude;
  final _locationNameController = TextEditingController();

  // === EXPIRY ===
  DateTime? _expiryDate;

  // === CUSTOM FIELDS ===
  List<CustomFieldDefinition> _customFields = [];

  // === PASS FIELD CONFIG ===
  bool _showStampsRemaining = true;
  bool _showCustomerName = false;
  bool _showMessage = false;
  bool _showRewards = true;
  bool _showBroadcastMessage = true;
  bool _showCustomField1 = false;
  bool _showCustomField2 = false;
  bool _showCustomField3 = false;
  final _stampsLabelController =
      TextEditingController(); // Empty - user can customize
  final _customerNameLabelController =
      TextEditingController(); // Empty - user can customize
  final _rewardsLabelController =
      TextEditingController(); // Empty - user can customize
  final _broadcastLabelController =
      TextEditingController(); // Empty - user can customize
  final _messageLabelController =
      TextEditingController(); // Empty by default - user can leave blank
  final _customMessageController = TextEditingController();
  final _customField1LabelController =
      TextEditingController(); // Empty - user can customize
  final _customField2LabelController =
      TextEditingController(); // Empty - user can customize
  final _customField3LabelController =
      TextEditingController(); // Empty - user can customize

  // Field priority order (drag-and-drop reorderable)
  // Order: stamps, customerName, customField1, customField2, customField3, broadcast
  List<String> _fieldPriorityOrder = [
    'stamps',
    'customerName',
    'customField1',
    'customField2',
    'customField3',
    'broadcast',
  ];

  // === LOCATION ENGAGEMENT ===
  bool _locationEnabled = false;
  int _locationRadius = 100; // Default 100m

  // === STAMP DISPLAY ===
  bool _useStampOpacity = true; // Default: opacity mode

  // Image picker
  final _imagePicker = ImagePicker();

  // Preset colors
  final List<Color> _presetColors = [
    const Color(0xFFFFFFFF), // White - first for visibility
    const Color(0xFF007AFF), // Blue
    const Color(0xFF34C759), // Green
    const Color(0xFFFF9500), // Orange
    const Color(0xFFFF3B30), // Red
    const Color(0xFFAF52DE), // Purple
    const Color(0xFF5856D6), // Indigo
    const Color(0xFFFF2D55), // Pink
    const Color(0xFF00C7BE), // Teal
    const Color(0xFFF5F5F7), // Light Gray (Apple style)
    const Color(0xFF8E8E93), // Gray
    const Color(0xFF1C1C1E), // Black
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    if (widget.programId == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(firestoreServiceProvider);
      final program = await service.getProgram(widget.programId!);

      if (program != null && mounted) {
        setState(() {
          _nameController.text = program.name;
          _descriptionController.text = program.description ?? '';
          _rewardController.text = program.rewardDescription;
          _stampsRequired = program.stampsRequired;

          _backgroundColor = _parseColor(program.backgroundColor);
          _foregroundColor = _parseColor(program.foregroundColor);
          _labelColor = _parseColor(program.labelColor);
          _accentColor = _parseColor(program.accentColor);

          _logoUrl = program.logoUrl;
          _iconUrl = program.iconUrl;
          _stripUrl = program.stripUrl;
          _stampActiveUrl = program.stampActiveUrl;
          _stampInactiveUrl = program.stampInactiveUrl;
          _stampStyle = program.stampStyle;

          _termsController.text = program.termsConditions ?? '';
          _websiteController.text = program.websiteUrl ?? '';
          _phoneController.text = program.phoneNumber ?? '';
          _emailController.text = program.email ?? '';
          _addressController.text = program.address ?? '';

          _latitude = program.latitude;
          _longitude = program.longitude;
          _locationNameController.text = program.locationName ?? '';

          _expiryDate = program.expiryDate;

          // Custom fields
          _customFields = List.from(program.customFields);

          // Pass field config
          _showStampsRemaining = program.passFieldConfig.showStampsRemaining;
          _showCustomerName = program.passFieldConfig.showCustomerName;
          _showMessage = program.passFieldConfig.showMessage;
          _showRewards = program.passFieldConfig.showRewards;
          _showBroadcastMessage = program.passFieldConfig.showBroadcastMessage;
          _showCustomField1 = program.passFieldConfig.showCustomField1;
          _showCustomField2 = program.passFieldConfig.showCustomField2;
          _showCustomField3 = program.passFieldConfig.showCustomField3;
          _stampsLabelController.text =
              program.passFieldConfig.stampsLabel ?? '';
          _customerNameLabelController.text =
              program.passFieldConfig.customerNameLabel ?? '';
          _rewardsLabelController.text =
              program.passFieldConfig.rewardsLabel ?? '';
          _broadcastLabelController.text =
              program.passFieldConfig.broadcastLabel ?? '';
          _messageLabelController.text =
              program.passFieldConfig.messageLabel ?? '';
          _customMessageController.text =
              program.passFieldConfig.customMessage ?? '';
          _customField1LabelController.text =
              program.passFieldConfig.customField1Label ?? '';
          _customField2LabelController.text =
              program.passFieldConfig.customField2Label ?? '';
          _customField3LabelController.text =
              program.passFieldConfig.customField3Label ?? '';

          // Load field priority order, ensuring all fields are present
          final savedOrder =
              List<String>.from(program.passFieldConfig.fieldPriorityOrder);
          // Remove deprecated 'message' field if present
          savedOrder.remove('message');
          const allFields = [
            'stamps',
            'customerName',
            'customField1',
            'customField2',
            'customField3',
            'broadcast'
          ];
          // Add any missing fields to the end
          for (final field in allFields) {
            if (!savedOrder.contains(field)) {
              savedOrder.add(field);
            }
          }
          // Remove any fields that are no longer valid
          savedOrder.removeWhere((f) => !allFields.contains(f));
          _fieldPriorityOrder = savedOrder;

          // Location engagement
          _locationEnabled = program.locationEnabled;
          _locationRadius = program.locationRadius;

          // Stamp display
          _useStampOpacity = program.useStampOpacity;
        });
      }
    } catch (e) {
      debugPrint('Error loading program: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF007AFF);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _termsController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _locationNameController.dispose();
    _stampsLabelController.dispose();
    _customerNameLabelController.dispose();
    _rewardsLabelController.dispose();
    _broadcastLabelController.dispose();
    _messageLabelController.dispose();
    _customMessageController.dispose();
    _customField1LabelController.dispose();
    _customField2LabelController.dispose();
    _customField3LabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(l10n.isRtl ? LucideIcons.arrowRight : LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.programId == null ? 'إنشاء برنامج جديد' : 'تعديل البرنامج',
          style: AppTypography.headline,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LoyaButton(
              label: 'حفظ',
              onPressed: _isSaving ? null : _saveProgram,
              isLoading: _isSaving,
              width: 100,
              height: 40,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(LucideIcons.info), text: 'الأساسيات'),
            Tab(icon: Icon(LucideIcons.palette), text: 'التصميم'),
            Tab(icon: Icon(LucideIcons.stamp), text: 'الأختام'),
            Tab(icon: Icon(LucideIcons.settings), text: 'إضافي'),
          ],
        ),
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Editor Panel
        Expanded(
          flex: 3,
          child: _buildEditorPanel(),
        ),
        // Preview Panel
        Expanded(
          flex: 2,
          child: _buildPreviewPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Compact Preview
        Container(
          height: 200,
          color: Colors.grey[100],
          child: _buildPreviewPanel(),
        ),
        // Editor
        Expanded(child: _buildEditorPanel()),
      ],
    );
  }

  Widget _buildEditorPanel() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBasicsTab(),
        _buildDesignTab(),
        _buildStampsTab(),
        _buildAdvancedTab(),
      ],
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'معاينة البطاقة',
                style: AppTypography.title.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              PassPreviewWidget(
                programName: _nameController.text.isEmpty
                    ? 'اسم البرنامج'
                    : _nameController.text,
                rewardDescription: _rewardController.text.isEmpty
                    ? 'المكافأة'
                    : _rewardController.text,
                stampsRequired: _stampsRequired,
                currentStamps: 3, // Demo value
                backgroundColor: _backgroundColor,
                foregroundColor: _foregroundColor,
                labelColor: _labelColor,
                logoUrl: _logoUrl,
                iconUrl: _iconUrl,
                stripUrl: _stripUrl,
                stampStyle: _stampStyle,
                customFields: _customFields,
                customFieldValues: {
                  // Sample values for preview
                  for (final field in _customFields) field.key: 'قيمة نموذجية',
                },
                useStampOpacity: _useStampOpacity,
                stampActiveUrl: _stampActiveUrl,
                stampInactiveUrl: _stampInactiveUrl,
                // New: Pass field config for priority-ordered fields
                passFieldConfig: PassFieldConfig(
                  showStampsRemaining: _showStampsRemaining,
                  stampsLabel: _stampsLabelController.text,
                  showCustomerName: _showCustomerName,
                  customerNameLabel: _customerNameLabelController.text,
                  showMessage: _showMessage,
                  messageLabel: _messageLabelController.text.isEmpty
                      ? 'رسالة'
                      : _messageLabelController.text,
                  customMessage: _customMessageController.text,
                  showRewards: _showRewards,
                  rewardsLabel: _rewardsLabelController.text,
                  showBroadcastMessage: _showBroadcastMessage,
                  broadcastLabel: _broadcastLabelController.text,
                  showCustomField1: _showCustomField1,
                  customField1Label: _customField1LabelController.text,
                  showCustomField2: _showCustomField2,
                  customField2Label: _customField2LabelController.text,
                  showCustomField3: _showCustomField3,
                  customField3Label: _customField3LabelController.text,
                  fieldPriorityOrder: _fieldPriorityOrder,
                ),
                fieldPriorityOrder: _fieldPriorityOrder,
                customerName: 'أحمد محمد', // Sample customer name
              ),
              const SizedBox(height: 16),
              Text(
                'هذه معاينة تقريبية\nالشكل الفعلي قد يختلف قليلاً في Apple Wallet',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === BASICS TAB ===
  Widget _buildBasicsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('معلومات البرنامج', LucideIcons.info),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'اسم البرنامج',
              hint: 'مثال: برنامج ولاء القهوة',
              icon: LucideIcons.type,
              required: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'الوصف (اختياري)',
              hint: 'وصف قصير للبرنامج',
              icon: LucideIcons.alignLeft,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _rewardController,
              label: 'وصف المكافأة',
              hint: 'مثال: اشترِ 8 واحصل على واحدة مجاناً',
              icon: LucideIcons.gift,
              required: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('عدد الأختام المطلوبة', LucideIcons.hash),
            const SizedBox(height: 16),
            _buildStampCounter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStampCounter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(
                icon: LucideIcons.minus,
                onPressed: _stampsRequired > 1
                    ? () => setState(() => _stampsRequired--)
                    : null,
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '$_stampsRequired',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ختم',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              _buildCounterButton(
                icon: LucideIcons.plus,
                onPressed: _stampsRequired < 12
                    ? () => setState(() => _stampsRequired++)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _stampsRequired.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
            activeColor: AppColors.primary,
            onChanged: (value) =>
                setState(() => _stampsRequired = value.round()),
          ),
          Text(
            'الحد الأقصى: 12 ختم (قيود Apple Wallet)',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null ? AppColors.primary : AppColors.divider,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  // === DESIGN TAB ===
  Widget _buildDesignTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('الألوان', LucideIcons.palette),
          const SizedBox(height: 16),
          _buildColorPicker(
            label: 'لون الخلفية',
            color: _backgroundColor,
            onColorChanged: (color) => setState(() => _backgroundColor = color),
          ),
          const SizedBox(height: 16),
          _buildColorPicker(
            label: 'لون النص',
            color: _foregroundColor,
            onColorChanged: (color) => setState(() => _foregroundColor = color),
          ),
          const SizedBox(height: 16),
          _buildColorPicker(
            label: 'لون التسميات',
            color: _labelColor,
            onColorChanged: (color) => setState(() => _labelColor = color),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('الصور', LucideIcons.image),
          const SizedBox(height: 16),
          // Responsive image uploaders - 3 in a row on desktop
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildImageUploader(
                    label: 'الشعار (Logo)',
                    hint: '160×50 بكسل - يظهر أعلى البطاقة',
                    currentUrl: _logoUrl,
                    onImageSelected: (url) => setState(() => _logoUrl = url),
                    aspectRatio: 160 / 50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageUploader(
                    label: 'الأيقونة (Icon)',
                    hint: '87×87 بكسل - تظهر في الإشعارات',
                    currentUrl: _iconUrl,
                    onImageSelected: (url) => setState(() => _iconUrl = url),
                    aspectRatio: 1,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageUploader(
                    label: 'صورة البانر (Strip)',
                    hint: '375×123 بكسل - تظهر في منتصف البطاقة',
                    currentUrl: _stripUrl,
                    onImageSelected: (url) => setState(() => _stripUrl = url),
                    aspectRatio: 375 / 123,
                  ),
                ),
              ],
            )
          else ...[
            // Mobile: stack vertically
            _buildImageUploader(
              label: 'الشعار (Logo)',
              hint: '160×50 بكسل - يظهر أعلى البطاقة',
              currentUrl: _logoUrl,
              onImageSelected: (url) => setState(() => _logoUrl = url),
              aspectRatio: 160 / 50,
            ),
            const SizedBox(height: 16),
            _buildImageUploader(
              label: 'الأيقونة (Icon)',
              hint: '87×87 بكسل - تظهر في الإشعارات',
              currentUrl: _iconUrl,
              onImageSelected: (url) => setState(() => _iconUrl = url),
              aspectRatio: 1,
            ),
            const SizedBox(height: 16),
            _buildImageUploader(
              label: 'صورة البانر (Strip)',
              hint: '375×123 بكسل - تظهر في منتصف البطاقة',
              currentUrl: _stripUrl,
              onImageSelected: (url) => setState(() => _stripUrl = url),
              aspectRatio: 375 / 123,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required Color color,
    required ValueChanged<Color> onColorChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.label),
                    Text(
                      _colorToHex(color),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Hex input button
              IconButton(
                onPressed: () => _showHexColorDialog(color, onColorChanged),
                icon: const Icon(LucideIcons.hash, size: 20),
                tooltip: 'إدخال كود اللون',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceSecondary,
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetColors.map((presetColor) {
              final isSelected = presetColor.value == color.value;
              final isLightColor = presetColor.computeLuminance() > 0.5;
              final checkColor = isLightColor ? Colors.black87 : Colors.white;
              final borderColor =
                  isLightColor ? AppColors.divider : Colors.transparent;
              return GestureDetector(
                onTap: () => onColorChanged(presetColor),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: presetColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: presetColor.withOpacity(0.4),
                                blurRadius: 8)
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(LucideIcons.check, color: checkColor, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showHexColorDialog(
      Color currentColor, ValueChanged<Color> onColorChanged) {
    final controller = TextEditingController(
        text: _colorToHex(currentColor).replaceFirst('#', ''));
    Color previewColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إدخال كود اللون', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
              ),
              const SizedBox(height: 16),
              // Input
              TextField(
                controller: controller,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  prefixText: '#',
                  prefixStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  hintText: 'FF5500',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLength: 6,
                onChanged: (value) {
                  final parsed = _tryParseHexColor(value);
                  if (parsed != null) {
                    setDialogState(() => previewColor = parsed);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = _tryParseHexColor(controller.text);
                if (parsed != null) {
                  onColorChanged(parsed);
                  Navigator.pop(context);
                }
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }

  Color? _tryParseHexColor(String hex) {
    hex = hex.replaceFirst('#', '').toUpperCase();
    if (hex.length == 6) {
      final intValue = int.tryParse(hex, radix: 16);
      if (intValue != null) {
        return Color(0xFF000000 + intValue);
      }
    }
    return null;
  }

  Widget _buildImageUploader({
    required String label,
    required String hint,
    required String? currentUrl,
    required ValueChanged<String?> onImageSelected,
    required double aspectRatio,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label),
          const SizedBox(height: 4),
          Text(
            hint,
            style:
                AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 12),
          if (currentUrl != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Image.network(
                      currentUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(LucideIcons.imageOff),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => onImageSelected(null),
                    icon: const Icon(LucideIcons.x),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () => _pickImage(onImageSelected, aspectRatio),
            icon: const Icon(LucideIcons.upload),
            label: Text(currentUrl == null ? 'رفع صورة' : 'تغيير الصورة'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
      ValueChanged<String?> onImageSelected, double aspectRatio) async {
    debugPrint('🖼️ _pickImage called');

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      debugPrint('🖼️ Image picked: ${image?.path}');

      if (image == null) {
        debugPrint('🖼️ No image selected');
        return;
      }

      setState(() => _isSaving = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('جاري رفع الصورة...'),
            duration: Duration(seconds: 2)),
      );

      final ref = FirebaseStorage.instance
          .ref()
          .child('programs')
          .child('${DateTime.now().millisecondsSinceEpoch}_${image.name}');

      debugPrint('🖼️ Uploading to: ${ref.fullPath}');

      // Works on both web and mobile
      final bytes = await image.readAsBytes();
      debugPrint('🖼️ Bytes read: ${bytes.length}');

      await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
      final url = await ref.getDownloadURL();

      debugPrint('🖼️ Upload success: $url');

      onImageSelected(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✓ تم رفع الصورة بنجاح'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🖼️ Image upload error: $e');
      debugPrint('🖼️ Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصورة: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // === STAMPS TAB ===
  Widget _buildStampsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('نمط الختم', LucideIcons.stamp),
          const SizedBox(height: 16),
          _buildStampStyleSelector(),
          const SizedBox(height: 32),
          _buildSectionHeader('أيقونات مخصصة', LucideIcons.image),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildImageUploader(
                  label: 'الختم النشط',
                  hint: 'يظهر للأختام المجمّعة',
                  currentUrl: _stampActiveUrl,
                  onImageSelected: (url) =>
                      setState(() => _stampActiveUrl = url),
                  aspectRatio: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageUploader(
                  label: 'الختم غير النشط',
                  hint: 'يظهر للأختام المتبقية',
                  currentUrl: _stampInactiveUrl,
                  onImageSelected: (url) =>
                      setState(() => _stampInactiveUrl = url),
                  aspectRatio: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStampStyleSelector() {
    final styles = [
      ('circle', 'دائرة', LucideIcons.circle),
      ('star', 'نجمة', LucideIcons.star),
      ('heart', 'قلب', LucideIcons.heart),
      ('check', 'صح', LucideIcons.checkCircle),
      ('coffee', 'قهوة', LucideIcons.coffee),
      ('custom', 'مخصص', LucideIcons.image),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: styles.map((style) {
          final isSelected = _stampStyle == style.$1;
          return GestureDetector(
            onTap: () => setState(() => _stampStyle = style.$1),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    style.$3,
                    size: 28,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    style.$2,
                    style: AppTypography.caption.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // === ADVANCED TAB ===
  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === PASS DISPLAY FIELDS ===
          _buildSectionHeader('حقول البطاقة', LucideIcons.creditCard),
          const SizedBox(height: 8),
          Text(
            'تحكم في الحقول التي تظهر على البطاقة',
            style:
                AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          _buildPassFieldsSection(),
          const SizedBox(height: 32),

          // === LOCATION ENGAGEMENT SECTION ===
          _buildSectionHeader('التفاعل بالموقع', LucideIcons.mapPin),
          const SizedBox(height: 8),
          Text(
            'إشعار العميل عند اقترابه من الموقع',
            style:
                AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          _buildLocationEngagementSection(),
          const SizedBox(height: 32),

          // === STAMP DISPLAY SECTION ===
          _buildSectionHeader('عرض الطوابع', LucideIcons.stamp),
          const SizedBox(height: 8),
          _buildStampDisplaySection(),
          const SizedBox(height: 32),

          _buildSectionHeader('معلومات الاتصال', LucideIcons.phone),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: '+966xxxxxxxxx',
            icon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'info@business.com',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _websiteController,
            label: 'الموقع الإلكتروني',
            hint: 'https://www.business.com',
            icon: LucideIcons.globe,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'العنوان',
            hint: 'المدينة، الحي، الشارع',
            icon: LucideIcons.mapPin,
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('الشروط والأحكام', LucideIcons.fileText),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _termsController,
            label: 'الشروط والأحكام',
            hint: 'أدخل شروط وأحكام برنامج الولاء...',
            icon: LucideIcons.fileText,
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('تاريخ الانتهاء', LucideIcons.calendar),
          const SizedBox(height: 16),
          _buildExpiryDatePicker(),
        ],
      ),
    );
  }

  // === PASS FIELDS CONFIG ===
  Widget _buildPassFieldsSection() {
    // Count enabled fields for limit warning
    int enabledCount = 0;
    if (_showStampsRemaining) enabledCount++;
    if (_showCustomerName) enabledCount++;
    if (_showBroadcastMessage) enabledCount++;

    // Build list of field configs based on priority order
    final fieldConfigs = <_FieldConfig>[];
    for (final fieldKey in _fieldPriorityOrder) {
      fieldConfigs.add(_getFieldConfig(fieldKey));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Priority info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabledCount > 4
                  ? AppColors.warning.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.gripVertical,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    enabledCount > 4
                        ? 'اسحب لتغيير الترتيب - الأولى 4 في الوجه، الباقي في الخلف ($enabledCount مفعّل)'
                        : 'اسحب لتغيير ترتيب الأولوية ($enabledCount/4 مفعّل)',
                    style: AppTypography.caption.copyWith(
                      color: enabledCount > 4
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Reorderable list of fields
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: fieldConfigs.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _fieldPriorityOrder.removeAt(oldIndex);
                _fieldPriorityOrder.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final config = fieldConfigs[index];
              final isInFront = _isFieldInFront(config.key, index);

              return Container(
                key: ValueKey(config.key),
                decoration: BoxDecoration(
                  color: isInFront ? Colors.white : Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    // Drag handle
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          LucideIcons.gripVertical,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    // Priority number
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isInFront
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Field content
                    Expanded(
                      child: _buildSimpleFieldRow(config, isInFront),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Non-reorderable fields (Rewards in header only)
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surfaceSecondary,
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text(
                  'حقول ثابتة (لا تؤثر على الترتيب)',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Rewards (Header - separate)
          _buildPassFieldRow(
            title: 'عدد المكافآت',
            subtitle: 'يظهر في أعلى البطاقة (Header)',
            value: _showRewards,
            onChanged: (v) => setState(() => _showRewards = v),
            labelController: _rewardsLabelController,
            labelHint: 'اسم الحقل (بالإنجليزية)',
          ),
        ],
      ),
    );
  }

  // Helper to check if field is in front (first 4 enabled fields)
  bool _isFieldInFront(String fieldKey, int priorityIndex) {
    int enabledBefore = 0;
    for (int i = 0; i < priorityIndex; i++) {
      if (_isFieldEnabled(_fieldPriorityOrder[i])) enabledBefore++;
    }
    return _isFieldEnabled(fieldKey) && enabledBefore < 4;
  }

  bool _isFieldEnabled(String fieldKey) {
    switch (fieldKey) {
      case 'stamps':
        return _showStampsRemaining;
      case 'customerName':
        return _showCustomerName;
      case 'broadcast':
        return _showBroadcastMessage;
      case 'customField1':
        return _showCustomField1;
      case 'customField2':
        return _showCustomField2;
      case 'customField3':
        return _showCustomField3;
      default:
        return false;
    }
  }

  _FieldConfig _getFieldConfig(String fieldKey) {
    switch (fieldKey) {
      case 'stamps':
        return _FieldConfig(
          key: 'stamps',
          title: 'عدد الأختام المتبقية',
          subtitle: 'مثال: "4 أختام للمكافأة"',
          value: _showStampsRemaining,
          onChanged: (v) => setState(() => _showStampsRemaining = v),
          labelController: _stampsLabelController,
          labelHint: 'اسم الحقل (بالإنجليزية)',
        );
      case 'customerName':
        return _FieldConfig(
          key: 'customerName',
          title: 'اسم العميل',
          subtitle: 'من قاعدة البيانات',
          value: _showCustomerName,
          onChanged: (v) => setState(() => _showCustomerName = v),
          labelController: _customerNameLabelController,
          labelHint: 'اسم الحقل (بالإنجليزية)',
          isCustomerField: true,
        );
      case 'broadcast':
        return _FieldConfig(
          key: 'broadcast',
          title: '📢 رسائل البث (Broadcast)',
          subtitle: 'رسائل ترسل من صفحة الرسائل',
          value: _showBroadcastMessage,
          onChanged: (v) => setState(() => _showBroadcastMessage = v),
          labelController: _broadcastLabelController,
          labelHint: 'Broadcast',
        );
      case 'customField1':
        return _FieldConfig(
          key: 'customField1',
          title: 'حقل مخصص 1',
          subtitle: 'حقل إضافي للعميل',
          value: _showCustomField1,
          onChanged: (v) => setState(() => _showCustomField1 = v),
          labelController: _customField1LabelController,
          labelHint: 'اسم الحقل (بالإنجليزية)',
        );
      case 'customField2':
        return _FieldConfig(
          key: 'customField2',
          title: 'حقل مخصص 2',
          subtitle: 'حقل إضافي للعميل',
          value: _showCustomField2,
          onChanged: (v) => setState(() => _showCustomField2 = v),
          labelController: _customField2LabelController,
          labelHint: 'اسم الحقل (بالإنجليزية)',
        );
      case 'customField3':
        return _FieldConfig(
          key: 'customField3',
          title: 'حقل مخصص 3',
          subtitle: 'حقل إضافي للعميل',
          value: _showCustomField3,
          onChanged: (v) => setState(() => _showCustomField3 = v),
          labelController: _customField3LabelController,
          labelHint: 'اسم الحقل (بالإنجليزية)',
        );
      default:
        return _FieldConfig(
          key: fieldKey,
          title: fieldKey,
          subtitle: '',
          value: false,
          onChanged: (_) {},
        );
    }
  }

  // Simple field row with guaranteed working toggle
  Widget _buildSimpleFieldRow(_FieldConfig config, bool isInFront) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            config.title,
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (config.isCustomerField) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.user,
                                    size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'عميل',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (config.key == 'broadcast') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.radio,
                                    size: 12, color: AppColors.warning),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isInFront
                            ? AppColors.success.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isInFront
                            ? '${config.subtitle} • الوجه'
                            : '${config.subtitle} • الخلف',
                        style: AppTypography.caption.copyWith(
                          color: isInFront
                              ? AppColors.success
                              : AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Custom styled toggle - tappable
              GestureDetector(
                onTap: () => config.onChanged(!config.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color:
                        config.value ? AppColors.primary : Colors.grey.shade300,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: config.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (config.value && config.labelController != null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: config.labelController,
              decoration: InputDecoration(
                labelText: 'اسم الحقل (بالإنجليزية)',
                hintText: config.labelHint,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              textDirection: TextDirection.ltr,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDraggableFieldRow(_FieldConfig config, bool isInFront) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Make the entire row tappable to toggle
          InkWell(
            onTap: () => config.onChanged(!config.value),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(config.title, style: AppTypography.label),
                          if (config.isCustomerField) ...[
                            const SizedBox(width: 6),
                            Icon(LucideIcons.user,
                                size: 14, color: AppColors.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isInFront
                            ? '${config.subtitle} • الوجه'
                            : '${config.subtitle} • الخلف',
                        style: AppTypography.caption.copyWith(
                          color: isInFront
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle - wrap in GestureDetector to ensure it receives taps
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => config.onChanged(!config.value),
                  child: AbsorbPointer(
                    child: Switch(
                      value: config.value,
                      onChanged: config.onChanged,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (config.value && config.labelController != null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: config.labelController,
              decoration: InputDecoration(
                labelText: 'اسم الحقل (بالإنجليزية)',
                hintText: config.labelHint,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              textDirection: TextDirection.ltr,
            ),
          ],
          if (config.value && config.contentController != null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: config.contentController,
              decoration: InputDecoration(
                labelText: 'محتوى الرسالة',
                hintText: config.contentHint,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPassFieldRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    TextEditingController? labelController,
    String? labelHint,
    TextEditingController? contentController,
    String? contentHint,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.label),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom styled toggle
              GestureDetector(
                onTap: () => onChanged(!value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: value ? AppColors.primary : Colors.grey.shade300,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment:
                        value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (value && labelController != null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'اسم الحقل (بالإنجليزية)',
                hintText: labelHint,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              textDirection: TextDirection.ltr,
            ),
          ],
          if (value && contentController != null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'محتوى الرسالة',
                hintText: contentHint,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  // === CUSTOM FIELDS ===
  Widget _buildCustomFieldsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // List existing fields
          ..._customFields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            return _buildCustomFieldRow(index, field);
          }),
          // Add new field button
          if (_customFields.where((f) => f.showOnFront).length < 4 ||
              _customFields.where((f) => !f.showOnFront).length < 10)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
              ),
              title: Text('إضافة حقل مخصص', style: AppTypography.body),
              onTap: _addCustomField,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomFieldRow(int index, CustomFieldDefinition field) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          // Enabled toggle
          Switch(
            value: field.enabled,
            onChanged: (value) {
              setState(() {
                _customFields[index] = field.copyWith(enabled: value);
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          // Label
          Expanded(
            child: GestureDetector(
              onTap: () => _editCustomFieldLabel(index),
              child: Text(
                field.label.isEmpty ? 'اسم الحقل' : field.label,
                style: AppTypography.body.copyWith(
                  color: field.label.isEmpty ? AppColors.textTertiary : null,
                ),
              ),
            ),
          ),
          // Position toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: field.showOnFront
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              onTap: () {
                // Check limits before toggling
                final frontCount =
                    _customFields.where((f) => f.showOnFront).length;
                final backCount =
                    _customFields.where((f) => !f.showOnFront).length;

                if (field.showOnFront && backCount >= 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('الحد الأقصى 10 حقول في الخلف')),
                  );
                  return;
                }
                if (!field.showOnFront && frontCount >= 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('الحد الأقصى 4 حقول في الوجه')),
                  );
                  return;
                }

                setState(() {
                  _customFields[index] =
                      field.copyWith(showOnFront: !field.showOnFront);
                });
              },
              child: Text(
                field.showOnFront ? 'الوجه' : 'الخلف',
                style: AppTypography.caption.copyWith(
                  color: field.showOnFront
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          IconButton(
            icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
            onPressed: () {
              setState(() {
                _customFields.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  void _addCustomField() {
    final frontCount = _customFields.where((f) => f.showOnFront).length;
    final showOnFront = frontCount < 4; // Default to front if space available

    setState(() {
      _customFields.add(CustomFieldDefinition(
        key: 'field_${DateTime.now().millisecondsSinceEpoch}',
        label: '',
        showOnFront: showOnFront,
        enabled: true,
      ));
    });

    // Open edit dialog for the new field
    _editCustomFieldLabel(_customFields.length - 1);
  }

  Future<void> _editCustomFieldLabel(int index) async {
    final controller = TextEditingController(text: _customFields[index].label);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اسم الحقل'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'مثال: رقم العضوية، الاسم...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _customFields[index] =
            _customFields[index].copyWith(label: result.trim());
      });
    }
  }

  // === LOCATION ENGAGEMENT ===
  Widget _buildLocationEngagementSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Enable toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تفعيل التنبيه بالموقع', style: AppTypography.body),
                    Text(
                      'إشعار العميل عند اقترابه من متجرك',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _locationEnabled,
                onChanged: (value) => setState(() => _locationEnabled = value),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          if (_locationEnabled) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Radius selector
            Row(
              children: [
                Icon(LucideIcons.radar,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text('نطاق التنبيه:', style: AppTypography.body),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [50, 100, 200, 500].map((radius) {
                      final isSelected = _locationRadius == radius;
                      return ChoiceChip(
                        label: Text('$radius م'),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _locationRadius = radius),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Location name input (use existing controller)
            _buildTextField(
              controller: _locationNameController,
              label: 'اسم الموقع',
              hint: 'مثال: الفرع الرئيسي',
              icon: LucideIcons.building,
            ),
            const SizedBox(height: 8),
            Text(
              'ملاحظة: يجب تحديد إحداثيات الموقع في إعدادات البرنامج',
              style:
                  AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  // === STAMP DISPLAY ===
  Widget _buildStampDisplaySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Opacity mode (recommended)
          _buildStampDisplayOption(
            title: 'وضع الشفافية (موصى به)',
            subtitle: 'الطوابع غير المكتملة تظهر بشفافية 30%',
            value: true,
            groupValue: _useStampOpacity,
            onChanged: (value) => setState(() => _useStampOpacity = value!),
          ),
          const Divider(),
          // Separate icons mode
          _buildStampDisplayOption(
            title: 'أيقونات منفصلة',
            subtitle: 'أيقونة مختلفة للطوابع غير المكتملة',
            value: false,
            groupValue: _useStampOpacity,
            onChanged: (value) => setState(() => _useStampOpacity = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildStampDisplayOption({
    required String title,
    required String subtitle,
    required bool value,
    required bool groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    return RadioListTile<bool>(
      title: Text(title, style: AppTypography.body),
      subtitle: Text(subtitle, style: AppTypography.caption),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildExpiryDatePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _expiryDate == null
                      ? 'بدون تاريخ انتهاء'
                      : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                  style: AppTypography.body,
                ),
                Text(
                  'البطاقة ستنتهي في هذا التاريخ',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (_expiryDate != null)
            IconButton(
              onPressed: () => setState(() => _expiryDate = null),
              icon: const Icon(LucideIcons.x),
            ),
          ElevatedButton(
            onPressed: _pickExpiryDate,
            child: Text(_expiryDate == null ? 'تحديد تاريخ' : 'تغيير'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  // === HELPERS ===
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: required
          ? (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null
          : null,
    );
  }

  // === SAVE ===
  Future<void> _saveProgram() async {
    // Validate name is not empty
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم البرنامج'),
          backgroundColor: Colors.red,
        ),
      );
      _tabController.animateTo(0); // Go to basics tab
      return;
    }

    setState(() => _isSaving = true);

    try {
      final businessId = ref.read(currentBusinessIdProvider);
      debugPrint('Saving program... businessId: $businessId');

      if (businessId == null) {
        throw Exception(
            'لم يتم العثور على المتجر - يرجى تسجيل الدخول مرة أخرى');
      }

      final program = LoyaltyProgram(
        id: widget.programId ?? '',
        businessId: businessId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        rewardDescription: _rewardController.text.trim().isEmpty
            ? 'مكافأة مجانية'
            : _rewardController.text.trim(),
        stampsRequired: _stampsRequired,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Design
        backgroundColor: _colorToHex(_backgroundColor),
        foregroundColor: _colorToHex(_foregroundColor),
        labelColor: _colorToHex(_labelColor),
        accentColor: _colorToHex(_accentColor),
        logoUrl: _logoUrl,
        iconUrl: _iconUrl,
        stripUrl: _stripUrl,
        stampActiveUrl: _stampActiveUrl,
        stampInactiveUrl: _stampInactiveUrl,
        stampStyle: _stampStyle,
        // Content
        termsConditions: _termsController.text.trim().isEmpty
            ? null
            : _termsController.text.trim(),
        websiteUrl: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        // Location
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationNameController.text.trim().isEmpty
            ? null
            : _locationNameController.text.trim(),
        // Expiry
        expiryDate: _expiryDate,
        // Custom fields
        customFields: _customFields,
        // Pass field config
        passFieldConfig: PassFieldConfig(
          showStampsRemaining: _showStampsRemaining,
          stampsLabel: _stampsLabelController.text.trim().isEmpty
              ? null
              : _stampsLabelController.text.trim(),
          showCustomerName: _showCustomerName,
          customerNameLabel: _customerNameLabelController.text.trim().isEmpty
              ? null
              : _customerNameLabelController.text.trim(),
          showMessage: _showMessage,
          customMessage: _customMessageController.text.trim().isEmpty
              ? null
              : _customMessageController.text.trim(),
          messageLabel: _messageLabelController.text.trim().isEmpty
              ? null
              : _messageLabelController.text.trim(),
          showRewards: _showRewards,
          rewardsLabel: _rewardsLabelController.text.trim().isEmpty
              ? null
              : _rewardsLabelController.text.trim(),
          showBroadcastMessage: _showBroadcastMessage,
          broadcastLabel: _broadcastLabelController.text.trim().isEmpty
              ? null
              : _broadcastLabelController.text.trim(),
          showCustomField1: _showCustomField1,
          customField1Label: _customField1LabelController.text.trim().isEmpty
              ? null
              : _customField1LabelController.text.trim(),
          showCustomField2: _showCustomField2,
          customField2Label: _customField2LabelController.text.trim().isEmpty
              ? null
              : _customField2LabelController.text.trim(),
          showCustomField3: _showCustomField3,
          customField3Label: _customField3LabelController.text.trim().isEmpty
              ? null
              : _customField3LabelController.text.trim(),
          fieldPriorityOrder: _fieldPriorityOrder,
        ),
        // Location engagement
        locationEnabled: _locationEnabled,
        locationRadius: _locationRadius,
        // Stamp display
        useStampOpacity: _useStampOpacity,
      );

      debugPrint('Program data: ${program.toJson()}');

      final firestoreService = ref.read(firestoreServiceProvider);
      final apiService = ApiService();

      if (widget.programId == null) {
        final newId = await firestoreService.createProgram(program);
        debugPrint('Created new program with ID: $newId');
      } else {
        // Use API service to update - this triggers pass notifications
        await apiService.updateProgram(widget.programId!, program.toJson());
        debugPrint('Updated program via API: ${widget.programId}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.programId == null
                ? 'تم إنشاء البرنامج بنجاح ✓'
                : 'تم حفظ التغييرات ✓'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving program: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// Helper class for field configuration
class _FieldConfig {
  final String key;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final TextEditingController? labelController;
  final String? labelHint;
  final TextEditingController? contentController;
  final String? contentHint;
  final bool isCustomerField;

  _FieldConfig({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.labelController,
    this.labelHint,
    this.isCustomerField = false,
  });
}
