import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/utils/current_user_photo_loader.dart';
import '../../../../shared/utils/current_user_session_storage.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/login_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';

/// Login screen with parent/student tabs.
class LoginScreen extends ConsumerStatefulWidget {
  final bool showSignupSuccess;

  const LoginScreen({super.key, this.showSignupSuccess = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final AnimationController _waterAnimationController;
  bool _reduceMotion = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _isLoading = false;

  // Dev autofill credentials (from API test data)
  static const String _studentEmail = 'siswaaja@gmail.com';
  static const String _studentPassword = 'Msi010803!';
  static const String _parentEmail = 'regiscaptcha@gmail.com';
  static const String _parentPassword = 'Msi010803!';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _waterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    )..repeat();
    _applyDevAutofillForIndex(_tabController.index);
    _hydrateRememberMe();

    if (widget.showSignupSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up berhasil. Silakan login.'),
            backgroundColor: AppColors.success,
          ),
        );
      });
    }
  }

  Future<void> _hydrateRememberMe() async {
    final saved = await readRememberMeEnabled();
    if (!mounted) {
      return;
    }
    setState(() => _rememberMe = saved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.maybeOf(context);
    final shouldReduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    if (_reduceMotion == shouldReduceMotion) {
      return;
    }

    _reduceMotion = shouldReduceMotion;
    if (_reduceMotion) {
      _waterAnimationController.stop(canceled: false);
    } else {
      _waterAnimationController.repeat();
    }
  }

  void _applyDevAutofillForIndex(int index) {
    final isParent = index == 1;
    _emailController.text = isParent ? _parentEmail : _studentEmail;
    _passwordController.text = isParent ? _parentPassword : _studentPassword;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _waterAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final isParent = _tabController.index == 1;
    final loginType = isParent ? 'parent' : 'student';

    try {
      final authRepository = ref.read(authRepositoryProvider);

      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        loginType: loginType,
      );

      final user = await authRepository.login(request);

      ref.read(currentUserProvider.notifier).state = user;
      await preloadCurrentUserPhoto(ref: ref, user: user);
      await saveRememberMeEnabled(_rememberMe);
      if (_rememberMe) {
        await saveCurrentUserSession(user);
      } else {
        await clearCurrentUserSession();
      }

      if (mounted) {
        setState(() => _isLoading = false);

        // Stop the background animation immediately before route switch.
        _waterAnimationController.stop(canceled: false);

        if (isParent) {
          context.go(AppRoutes.parentDashboard);
        } else {
          context.go(AppRoutes.studentDashboard);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('An unexpected error occurred');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppDimensions.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _waterAnimationController,
                builder: (context, _) {
                  return RepaintBoundary(
                    child: CustomPaint(
                      painter: _WaterBackgroundPainter(
                        progress: _reduceMotion
                            ? 0
                            : _waterAnimationController.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingXL),
                  // Logo
                  Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.logo,
                            width: AppDimensions.logoL,
                            height: AppDimensions.logoL,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: AppDimensions.logoL,
                                height: AppDimensions.logoL,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.school,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ),
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
                        'Login',
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: _applyDevAutofillForIndex,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
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
                            child: Text('Login as Student'),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Login as Parent'),
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
                              label: 'Email',
                              hint: 'Enter your email',
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
                              delay: const Duration(milliseconds: 400),
                              duration: const Duration(milliseconds: 400),
                            )
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: AppDimensions.paddingM),
                        AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              obscureText: true,
                              prefixIcon: Iconsax.lock,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 8 characters';
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
                                      setState(
                                        () => _rememberMe = value ?? false,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingS),
                                Text(
                                  'Remember me',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                final loginType = _tabController.index == 1
                                    ? 'parent'
                                    : 'student';
                                context.push(
                                  '${AppRoutes.forgotPassword}?loginType=$loginType',
                                );
                              },
                              child: Text(
                                'Forgot Password?',
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
                              text: 'Login',
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
                              'Don\'t have an account?',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(AppRoutes.signup),
                              child: Text(
                                'Sign Up',
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
        ],
      ),
    );
  }
}

class _WaterBackgroundPainter extends CustomPainter {
  final double progress;

  const _WaterBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.background,
          AppColors.primary.withValues(alpha: 0.03),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, basePaint);

    final waveOnePath = _buildWavePath(
      size: size,
      baseHeightFactor: 0.68,
      amplitude: 20,
      frequency: 1.5,
      phaseShift: progress * 2 * math.pi,
    );

    final waveTwoPath = _buildWavePath(
      size: size,
      baseHeightFactor: 0.74,
      amplitude: 26,
      frequency: 1.2,
      phaseShift: (progress * 2 * math.pi) + (math.pi / 2),
    );

    final waveOnePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final waveTwoPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;

    canvas.drawPath(waveOnePath, waveOnePaint);
    canvas.drawPath(waveTwoPath, waveTwoPaint);
  }

  Path _buildWavePath({
    required Size size,
    required double baseHeightFactor,
    required double amplitude,
    required double frequency,
    required double phaseShift,
  }) {
    if (size.width <= 0 || size.height <= 0) {
      return Path();
    }

    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, size.height * baseHeightFactor);
    final samplingStep = (size.width / 60).clamp(6.0, 14.0);

    for (double x = 0; x <= size.width; x += samplingStep) {
      final normalizedX = x / size.width;
      final y =
          (size.height * baseHeightFactor) +
          (math.sin((normalizedX * frequency * 2 * math.pi) + phaseShift) *
              amplitude);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _WaterBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
