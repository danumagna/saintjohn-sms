import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

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
      await _authRepository.signupParent(
        nameParent: _nameController.text.trim(),
        emailParent: _emailController.text.trim(),
        phoneParent: _phoneController.text.trim(),
        passwordParent: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.tick_circle,
                      color: AppColors.success,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  const Text(
                    'Sign up berhasil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  const Text(
                    'Akun berhasil dibuat. Silakan lanjut login untuk masuk ke aplikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        minimumSize: const Size.fromHeight(
                          AppDimensions.buttonHeightM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.go(AppRoutes.login);
                      },
                      child: const Text(
                        'Ke Halaman Login',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
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
          content: Text('Something went wrong'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

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
                      'Create Account',
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
                          'Sign up as Parent',
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
                      label: 'Parent/Guardian full name',
                      hint: 'Enter parent/guardian full name',
                      prefixIcon: Iconsax.user,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
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
                      label: 'Parent/Guardian email address',
                      hint: 'Enter parent/guardian email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Iconsax.sms,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
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
                      label: 'Retype email address',
                      hint: 'Retype email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Iconsax.sms_tracking,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        if (value.trim() != _emailController.text.trim()) {
                          return 'Email addresses do not match';
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
                      label: 'Parent/Guardian phone number',
                      hint: 'Enter parent/guardian phone number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Iconsax.call,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
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
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: true,
                      prefixIcon: Iconsax.lock,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
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
                      label: 'Retype password',
                      hint: 'Retype password',
                      obscureText: true,
                      prefixIcon: Iconsax.lock,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
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
                        'I agree to the Terms & Conditions',
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
                      text: 'Sign Up',
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
                      'Already have an account?',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        'Login',
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



