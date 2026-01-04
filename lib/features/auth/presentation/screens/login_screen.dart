import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/loya_button.dart';
import '../../../shared/widgets/loya_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _phoneNumber = '';
  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    // Listen for navigation
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.codeSent) {
        context.pushNamed('otp', extra: _phoneNumber);
      }
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get(next.errorMessage!)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const LoyaLogo(size: 80),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Welcome Text
                  Text(
                    l10n.get('welcome_back'),
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.get('sign_in_to_continue'),
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sectionMedium),

                  // Phone Input Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('phone_number'),
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: IntlPhoneField(
                            decoration: InputDecoration(
                              hintText: l10n.get('enter_phone'),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                            ),
                            initialCountryCode: 'SA',
                            disableLengthCheck: false,
                            dropdownTextStyle: AppTypography.body,
                            style: AppTypography.body,
                            flagsButtonPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            showDropdownIcon: true,
                            dropdownIconPosition: IconPosition.trailing,
                            onChanged: (phone) {
                              setState(() {
                                _phoneNumber = phone.completeNumber;
                                _isValid = phone.isValidNumber();
                              });
                            },
                            onCountryChanged: (country) {
                              // Reset validation when country changes
                              setState(() {
                                _isValid = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        LoyaButton(
                          label: l10n.get('continue_btn'),
                          onPressed:
                              _isValid && !isLoading ? () => _sendOtp() : null,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Tagline
                  Text(
                    l10n.appTagline,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendOtp() {
    ref.read(authNotifierProvider.notifier).sendOtp(_phoneNumber);
  }
}
