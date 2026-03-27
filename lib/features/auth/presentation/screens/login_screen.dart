import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/data/dummy/dummy_users.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

/// Login screen with parent/student tabs.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  // Temporary dev autofill credentials.
  static const String _parentEmail = 'danuparent@saintjohn.com';
  static const String _studentEmail = 'danustudent@saintjohn.com';
  static const String _defaultPassword = 'saintjohn1!';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _applyDevAutofillForIndex(_tabController.index);
  }

  void _applyDevAutofillForIndex(int index) {
    final isParent = index == 1;
    _emailController.text = isParent ? _parentEmail : _studentEmail;
    _passwordController.text = _defaultPassword;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final isParent = _tabController.index == 1;
    final user = isParent
        ? DummyUsers.getDefaultParent()
        : DummyUsers.getDefaultStudent();

    ref.read(currentUserProvider.notifier).state = user;

    if (mounted) {
      setState(() => _isLoading = false);

      if (isParent) {
        context.go(AppRoutes.parentDashboard);
      } else {
        context.go(AppRoutes.studentDashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingXL),
              // Logo
              Image.asset(
                    AppAssets.logo,
                    width: AppDimensions.logoL,
                    height: AppDimensions.logoL,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: AppDimensions.logoL,
                        height: AppDimensions.logoL,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: AppDimensions.paddingL),
              // Title
              Text(
                    l10n.authLoginTitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                  )
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimensions.paddingXL),
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: _applyDevAutofillForIndex,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.textOnPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: [
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.authLoginAsStudent),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.authLoginAsParent),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                          controller: _emailController,
                          label: l10n.authEmailLabel,
                          hint: l10n.authEmailHint,
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
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 400),
                        )
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: AppDimensions.paddingM),
                    AppTextField(
                          controller: _passwordController,
                          label: l10n.authPasswordLabel,
                          hint: l10n.authPasswordHint,
                          obscureText: true,
                          prefixIcon: Iconsax.lock,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.validationRequired;
                            }
                            if (value.length < 6) {
                              return l10n.validationPasswordMin;
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
                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() => _rememberMe = value ?? false);
                                },
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            Text(
                              l10n.authRememberMe,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.forgotPassword),
                          child: Text(
                            l10n.authForgotPassword,
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
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 400),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                    // Login Button
                    PrimaryButton(
                          text: l10n.authLogin,
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        )
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 700),
                          duration: const Duration(milliseconds: 400),
                        )
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: AppDimensions.paddingL),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.authNoAccount,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.signup),
                          child: Text(
                            l10n.authSignUp,
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
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 400),
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
}
