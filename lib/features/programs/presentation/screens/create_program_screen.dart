import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../shared/widgets/loya_button.dart';
import '../widgets/program_preview.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  ConsumerState<CreateProgramScreen> createState() =>
      _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController();

  int _stampsRequired = 8;
  Color _selectedColor = AppColors.programBlue;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
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
          l10n.get('create_program'),
          style: AppTypography.headline,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: LoyaButton(
              label: l10n.get('save'),
              onPressed: _isLoading ? null : _saveProgram,
              isLoading: _isLoading,
              width: 100,
              height: 40,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
            isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child:
                isMobile ? _buildMobileLayout(l10n) : _buildDesktopLayout(l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form
        Expanded(
          flex: 3,
          child: _buildForm(l10n),
        ),
        const SizedBox(width: 32),
        // Preview
        Expanded(
          flex: 2,
          child: _buildPreviewSection(l10n),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n) {
    return Column(
      children: [
        _buildPreviewSection(l10n),
        const SizedBox(height: 24),
        _buildForm(l10n),
      ],
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Name
            _FormSection(
              label: l10n.get('program_name'),
              child: TextFormField(
                controller: _nameController,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'e.g., Coffee Rewards',
                ),
                maxLength: AppConfig.maxProgramNameLength,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a program name';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            _FormSection(
              label: l10n.get('program_description'),
              child: TextFormField(
                controller: _descriptionController,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'e.g., Collect stamps, get free coffee',
                ),
                maxLength: AppConfig.maxDescriptionLength,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 24),

            // Stamps Required
            _FormSection(
              label: l10n.get('stamps_required'),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _selectedColor,
                            inactiveTrackColor: _selectedColor.withOpacity(0.2),
                            thumbColor: _selectedColor,
                            overlayColor: _selectedColor.withOpacity(0.1),
                          ),
                          child: Slider(
                            value: _stampsRequired.toDouble(),
                            min: 4,
                            max: AppConfig.maxStampsPerProgram.toDouble(),
                            divisions: AppConfig.maxStampsPerProgram - 4,
                            onChanged: (value) {
                              setState(() {
                                _stampsRequired = value.round();
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$_stampsRequired',
                          style: AppTypography.numberSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStampPreview(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reward Description
            _FormSection(
              label: l10n.get('reward_description'),
              child: TextFormField(
                controller: _rewardController,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'e.g., Free coffee of your choice',
                ),
                maxLength: AppConfig.maxDescriptionLength,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the reward';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 24),

            // Color Selection
            _FormSection(
              label: l10n.get('program_color'),
              child: _buildColorPicker(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStampPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(_stampsRequired, (index) {
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColor.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTypography.captionSmall.copyWith(
                  color: _selectedColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      AppColors.programBlue,
      AppColors.programGreen,
      AppColors.programOrange,
      AppColors.programRed,
      AppColors.programPurple,
      AppColors.programIndigo,
      AppColors.programTeal,
      AppColors.programPink,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.textPrimary, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('program_preview'),
          style: AppTypography.title.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ProgramPreview(
          name: _nameController.text.isEmpty
              ? 'Program Name'
              : _nameController.text,
          description: _descriptionController.text.isEmpty
              ? 'Program description'
              : _descriptionController.text,
          stampsRequired: _stampsRequired,
          reward: _rewardController.text.isEmpty
              ? 'Your reward'
              : _rewardController.text,
          color: _selectedColor,
        ),
      ],
    );
  }

  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the program notifier to create program
      final programNotifier = ref.read(programNotifierProvider.notifier);

      // Convert color to hex string
      final colorHex =
          '#${_selectedColor.value.toRadixString(16).substring(2)}';

      // Create the program in Firestore
      final programId = await programNotifier.createProgram(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        rewardDescription: _rewardController.text.trim().isEmpty
            ? 'مكافأة مجانية'
            : _rewardController.text.trim(),
        stampsRequired: _stampsRequired,
        color: colorHex,
        icon: 'gift',
      );

      if (programId != null && mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.get('success')),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        throw Exception('فشل في إنشاء البرنامج');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Form section wrapper
class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormSection({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
