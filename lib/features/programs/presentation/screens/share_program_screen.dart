import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/data/providers/data_providers.dart';

class ShareProgramScreen extends ConsumerWidget {
  final String programId;

  const ShareProgramScreen({
    super.key,
    required this.programId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final programsAsync = ref.watch(programsProvider);

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
          'مشاركة البرنامج',
          style: AppTypography.headline,
        ),
      ),
      body: programsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (programs) {
          final program = programs.where((p) => p.id == programId).firstOrNull;
          if (program == null) {
            return const Center(child: Text('البرنامج غير موجود'));
          }
          return _buildContent(context, program, l10n);
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, LoyaltyProgram program, AppLocalizations l10n) {
    final joinUrl =
        'https://loya-app-ziqygx-9bc8a.web.app/join/?program=${program.id}';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
          isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // QR Code Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    // Program info
                    Text(
                      program.name,
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${program.stampsRequired} طوابع = ${program.rewardDescription}',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.borderLight, width: 2),
                      ),
                      child: QrImageView(
                        data: joinUrl,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.scanLine,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'العميل يمسح الكود بجواله للانضمام',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Share Link Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رابط الانضمام',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // URL Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              joinUrl,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(LucideIcons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: joinUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم نسخ الرابط'),
                                  backgroundColor: AppColors.success,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: 'نسخ الرابط',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Share buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ShareButton(
                            icon: LucideIcons.messageCircle,
                            label: 'واتساب',
                            color: const Color(0xFF25D366),
                            onTap: () => _shareToWhatsApp(
                                context, joinUrl, program.name),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ShareButton(
                            icon: LucideIcons.share2,
                            label: 'مشاركة',
                            color: AppColors.primary,
                            onTap: () =>
                                _shareGeneric(context, joinUrl, program.name),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // How it works
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كيف يعمل؟',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StepItem(
                      number: '1',
                      title: 'العميل يمسح الكود',
                      subtitle: 'أو يفتح الرابط',
                    ),
                    _StepItem(
                      number: '2',
                      title: 'يسجل برقم جواله',
                      subtitle: 'اسم واختياري تاريخ الميلاد',
                    ),
                    _StepItem(
                      number: '3',
                      title: 'يحمّل بطاقة Apple Wallet',
                      subtitle: 'البطاقة تُضاف لمحفظته',
                    ),
                    _StepItem(
                      number: '4',
                      title: 'يجمع الطوابع',
                      subtitle: 'كل زيارة = طابع جديد',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareToWhatsApp(BuildContext context, String url, String programName) {
    final message =
        'انضم لبرنامج الولاء "$programName" واحصل على مكافآت! 🎁\n\n$url';
    // For web, copy to clipboard since we can't directly open WhatsApp
    // TODO: Use url_launcher for mobile platforms
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرسالة - الصقها في واتساب'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareGeneric(BuildContext context, String url, String programName) {
    final message =
        'انضم لبرنامج الولاء "$programName" واحصل على مكافآت!\n$url';
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرسالة'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.buttonSmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isLast;

  const _StepItem({
    required this.number,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTypography.buttonSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
