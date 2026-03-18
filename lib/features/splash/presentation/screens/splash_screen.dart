import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../routing/app_router.dart';

/// Splash screen with animated logo and app name.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(AppDurations.splash);
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.secondary,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo
              Image.asset(
                    AppAssets.logo,
                    width: AppDimensions.logoXL,
                    height: AppDimensions.logoXL,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: AppDimensions.logoXL,
                        height: AppDimensions.logoXL,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 80,
                          color: AppColors.textOnPrimary,
                        ),
                      );
                    },
                  )
                  .animate()
                  .fadeIn(duration: AppDurations.slow, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: AppDurations.slow,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: AppDimensions.paddingXL),
              // App Name
              const Text(
                    'Saint John',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 300),
                    duration: AppDurations.normal,
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: const Duration(milliseconds: 300),
                    duration: AppDurations.normal,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: AppDimensions.paddingS),
              const Text(
                    'School Management System',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textOnPrimary,
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 500),
                    duration: AppDurations.normal,
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: const Duration(milliseconds: 500),
                    duration: AppDurations.normal,
                    curve: Curves.easeOut,
                  ),
              const Spacer(flex: 2),
              // Loading Indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textOnPrimary,
                  ),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 800),
                duration: AppDurations.normal,
              ),
              const Spacer(),
              // Version
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 1000),
                duration: AppDurations.normal,
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
      ),
    );
  }
}
