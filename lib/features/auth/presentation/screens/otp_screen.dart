import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/config/app_config.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/loya_button.dart';
import '../../../shared/widgets/loya_logo.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _resendCountdown = AppConfig.otpResendDelay;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = AppConfig.otpResendDelay;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final isVerifying = authState.status == AuthStatus.verifying;

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/');
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

    // Pin theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTypography.headline.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error, width: 1),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            l10n.isRtl ? Icons.arrow_forward : Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            ref.read(authNotifierProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
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
                  const LoyaLogo(size: 60),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Title
                  Text(
                    l10n.get('verification_code'),
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Subtitle with phone number
                  Text(
                    l10n.get('enter_otp'),
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      widget.phoneNumber,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionMedium),

                  // OTP Input Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      children: [
                        // OTP Input
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            controller: _otpController,
                            length: 6,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            errorPinTheme: errorPinTheme,
                            pinAnimationType: PinAnimationType.fade,
                            animationDuration:
                                const Duration(milliseconds: 200),
                            showCursor: true,
                            cursor: Container(
                              width: 2,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            onCompleted: (code) {
                              _verifyOtp(code);
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Verify Button
                        LoyaButton(
                          label: l10n.get('verify'),
                          onPressed:
                              !isVerifying && _otpController.text.length == 6
                                  ? () => _verifyOtp(_otpController.text)
                                  : null,
                          isLoading: isVerifying,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Resend Section
                        if (_canResend)
                          TextButton(
                            onPressed: _resendOtp,
                            child: Text(
                              l10n.get('resend_code'),
                              style: AppTypography.button.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else
                          Text(
                            '${l10n.get('resend_in')} $_resendCountdown ${l10n.get('seconds')}',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Change Number
                  TextButton(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).reset();
                      context.pop();
                    },
                    child: Text(
                      '${l10n.get('wrong_number')} ${l10n.get('change_number')}',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOtp(String code) {
    ref.read(authNotifierProvider.notifier).verifyOtp(code);
  }

  void _resendOtp() {
    ref.read(authNotifierProvider.notifier).resendOtp();
    _startResendTimer();
  }
}
