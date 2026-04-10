import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

/// Sign up screen for new users.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check the terms and conditions before continue'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _authRepository.signupParent(
        nameParent: _nameController.text.trim(),
        emailParent: _emailController.text.trim(),
        phoneParent: _phoneController.text.trim(),
        passwordParent: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );

      context.go(AppRoutes.login);
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
        SnackBar(
          content: Text(l10n.commonError),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                      l10n.authSignUpTitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppDimensions.paddingXL),
                // Parent-only signup info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.people,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Expanded(
                        child: Text(
                          l10n.authSignUpAsParent,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 400),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                // Full Name
                AppTextField(
                      controller: _nameController,
                      label: l10n.authGuardianNameLabel,
                      hint: l10n.authGuardianNameHint,
                      prefixIcon: Iconsax.user,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                // Email
                AppTextField(
                      controller: _emailController,
                      label: l10n.authGuardianEmailLabel,
                      hint: l10n.authGuardianEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Iconsax.sms,
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
                const SizedBox(height: AppDimensions.paddingM),
                // Confirm Email
                AppTextField(
                      controller: _confirmEmailController,
                      label: l10n.authConfirmEmailLabel,
                      hint: l10n.authConfirmEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Iconsax.sms_tracking,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        if (!value.contains('@')) {
                          return l10n.validationEmail;
                        }
                        if (value.trim() != _emailController.text.trim()) {
                          return l10n.validationEmailMatch;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                // Phone
                AppTextField(
                      controller: _phoneController,
                      label: l10n.authGuardianPhoneLabel,
                      hint: l10n.authGuardianPhoneHint,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Iconsax.call,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                // Password
                AppTextField(
                      controller: _passwordController,
                      label: l10n.authPasswordLabel,
                      hint: l10n.authPasswordHint,
                      obscureText: true,
                      prefixIcon: Iconsax.lock,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        if (value.length < 8) {
                          return l10n.validationPasswordMin;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                // Confirm Password
                AppTextField(
                      controller: _confirmPasswordController,
                      label: l10n.authRetypePasswordLabel,
                      hint: l10n.authRetypePasswordHint,
                      obscureText: true,
                      prefixIcon: Iconsax.lock,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.validationPasswordMatch;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                // Terms & Conditions
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: Text(
                        l10n.authAgreeTerms,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(
                  delay: const Duration(milliseconds: 800),
                  duration: const Duration(milliseconds: 400),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                // Sign Up Button
                PrimaryButton(
                      text: l10n.authSignUp,
                      isLoading: _isLoading,
                      onPressed: _handleSignUp,
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 900),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppDimensions.paddingL),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.authHaveAccount,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        l10n.authLogin,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(
                  delay: const Duration(milliseconds: 1000),
                  duration: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
