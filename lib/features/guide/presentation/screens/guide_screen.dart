import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Guide screen with help and tutorial information.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final guides = [
      _GuideItem(
        icon: Iconsax.login,
        title: 'Getting Started',
        description: 'Learn how to log in and navigate the app',
        steps: [
          'Open the app and select your user type',
          'Enter your email and password',
          'Tap the Login button to access your dashboard',
        ],
      ),
      _GuideItem(
        icon: Iconsax.user_add,
        title: 'Student Registration',
        description: 'How to register a new student',
        steps: [
          'Go to Students > Registration from the dashboard',
          'Fill in all required student information',
          'Tap Register to complete the registration',
        ],
      ),
      _GuideItem(
        icon: Iconsax.calendar,
        title: 'View Schedule',
        description: 'Check class and exam schedules',
        steps: [
          'Navigate to Schedule from the dashboard',
          'Select the day to view classes',
          'Tap on a class for more details',
        ],
      ),
      _GuideItem(
        icon: Iconsax.chart,
        title: 'Check Progress',
        description: 'Monitor academic progress and attendance',
        steps: [
          'Go to Reports from the dashboard',
          'Select the type of report you want to view',
          'Review the detailed information',
        ],
      ),
      _GuideItem(
        icon: Iconsax.setting_2,
        title: 'Settings',
        description: 'Customize your app experience',
        steps: [
          'Tap Settings in the bottom navigation',
          'Update your profile, language, or notifications',
          'Changes are saved automatically',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.guideTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        itemCount: guides.length,
        itemBuilder: (context, index) {
          final guide = guides[index];
          return _buildGuideCard(guide, index);
        },
      ),
    );
  }

  Widget _buildGuideCard(_GuideItem guide, int index) {
    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Theme(
            data: ThemeData(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(AppDimensions.paddingM),
              childrenPadding: const EdgeInsets.only(
                left: AppDimensions.paddingL,
                right: AppDimensions.paddingL,
                bottom: AppDimensions.paddingM,
              ),
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(guide.icon, color: AppColors.primary),
              ),
              title: Text(
                guide.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingXS),
                child: Text(
                  guide.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: guide.steps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingS,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(begin: 0.1, end: 0);
  }
}

class _GuideItem {
  final IconData icon;
  final String title;
  final String description;
  final List<String> steps;

  const _GuideItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.steps,
  });
}
