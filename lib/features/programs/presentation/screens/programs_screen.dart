import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/models/models.dart';
import '../../../shared/widgets/loya_button.dart';
import '../widgets/program_card.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;

    // Watch real programs from Firebase
    final programsAsync = ref.watch(programsProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(
              isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
              child: programsAsync.when(
            loading: () => _buildLoading(),
            error: (error, stack) => _buildError(error, ref),
            data: (programs) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('my_programs'),
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${programs.length} ${l10n.get('programs').toLowerCase()}',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Only show create button in header on desktop
                    if (!isMobile)
                      SizedBox(
                        width: 180,
                        child: LoyaButton(
                          label: l10n.get('create_program'),
                          icon: LucideIcons.plus,
                          onPressed: () => context.push('/programs/create'),
                          height: 44,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sectionSmall),

                // Programs grid
                if (programs.isEmpty)
                  _buildEmptyState(context, l10n)
                else
                  _buildProgramsGrid(context, programs, isMobile),
                
                // Add bottom spacing for FAB on mobile
                if (isMobile) const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    ),
    // Floating Action Button for mobile
    if (isMobile)
      Positioned(
        left: 16,
        right: 16,
        bottom: 16,
        child: SafeArea(
          child: LoyaButton(
            label: l10n.get('create_program'),
            icon: LucideIcons.plus,
            onPressed: () => context.push('/programs/create'),
            height: 52,
          ),
        ),
      ),
    ],
  );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildError(Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('حدث خطأ: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(programsProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.gift,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('no_programs_yet'),
              style: AppTypography.headline.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('create_first_program'),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LoyaButton(
                label: l10n.get('create_program'),
                icon: LucideIcons.plus,
                onPressed: () => context.push('/programs/create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsGrid(
      BuildContext context, List<LoyaltyProgram> programs, bool isMobile) {
    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: programs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => ProgramCard(
          program: programs[index],
          onTap: () => context.push('/programs/${programs[index].id}/edit'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.6,
      ),
      itemCount: programs.length,
      itemBuilder: (context, index) => ProgramCard(
        program: programs[index],
        onTap: () => context.push('/programs/${programs[index].id}/edit'),
      ),
    );
  }
}
