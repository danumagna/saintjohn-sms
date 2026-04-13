import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';

/// Forgot password screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? loginType;

  const ForgotPasswordScreen({super.key, this.loginType});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  String get _resolvedLoginType {
    final rawLoginType = (widget.loginType ?? '').trim().toLowerCase();
    if (rawLoginType == 'student' || rawLoginType == 'parent') {
      return rawLoginType;
    }
    return 'parent';
  }

  String get _accountTypeLabel {
    return _resolvedLoginType == 'student' ? 'Student' : 'Parent';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.sendForgotPasswordValidation(
        email: _emailController.text.trim(),
        loginType: _resolvedLoginType,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: _emailSent ? _buildSuccessState(l10n) : _buildForm(l10n),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.lock,
                  size: 48,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: AppDimensions.paddingXL),
          // Title
          Text(
                l10n.authForgotPasswordTitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
              )
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppDimensions.paddingS),
          // Description
          Text(
            l10n.authForgotPasswordDesc,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.user, size: 14, color: AppColors.primary),
                const SizedBox(width: AppDimensions.paddingXS),
                Text(
                  'Account Type: $_accountTypeLabel',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 240),
            duration: const Duration(milliseconds: 350),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          // Email Field
          AppTextField(
                controller: _emailController,
                label: l10n.authEmailLabel,
                hint: l10n.authEmailHint,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Iconsax.sms,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.validationRequired;
                  }
                  if (!value.contains('@')) {
                    return l10n.validationEmail;
                  }
                  return null;
                },
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 400),
              )
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: AppDimensions.paddingXL),
          // Send Reset Link Button
          PrimaryButton(
                text: l10n.authSendResetLink,
                isLoading: _isLoading,
                onPressed: _handleSendResetLink,
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 400),
              )
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppDimensions.paddingL),
          // Back to Login
          Center(
            child: TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: Text(
                l10n.authBackToLogin,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 400),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimensions.paddingXXL),
        Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                size: 64,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 400))
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: AppDimensions.paddingXL),
        const Text(
          'Check your email',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Text(
          'We have sent a password reset link to\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
        ),
        const SizedBox(height: AppDimensions.paddingXXL),
        PrimaryButton(
          text: l10n.authBackToLogin,
          onPressed: () => context.go(AppRoutes.login),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }
}
