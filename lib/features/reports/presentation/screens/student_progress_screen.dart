import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Subject progress item model.
class SubjectProgress {
  final String subject;
  final double progress;
  final String grade;
  final int completedTopics;
  final int totalTopics;
  final Color color;

  const SubjectProgress({
    required this.subject,
    required this.progress,
    required this.grade,
    required this.completedTopics,
    required this.totalTopics,
    required this.color,
  });
}

/// Student Progress screen showing academic achievements.
class StudentProgressScreen extends StatelessWidget {
  const StudentProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final subjects = [
      const SubjectProgress(
        subject: 'Mathematics',
        progress: 0.85,
        grade: 'A',
        completedTopics: 17,
        totalTopics: 20,
        color: Colors.blue,
      ),
      const SubjectProgress(
        subject: 'Physics',
        progress: 0.78,
        grade: 'B+',
        completedTopics: 14,
        totalTopics: 18,
        color: Colors.purple,
      ),
      const SubjectProgress(
        subject: 'Chemistry',
        progress: 0.82,
        grade: 'A-',
        completedTopics: 16,
        totalTopics: 20,
        color: Colors.orange,
      ),
      const SubjectProgress(
        subject: 'Biology',
        progress: 0.95,
        grade: 'A+',
        completedTopics: 19,
        totalTopics: 20,
        color: Colors.teal,
      ),
      const SubjectProgress(
        subject: 'English',
        progress: 0.90,
        grade: 'A',
        completedTopics: 18,
        totalTopics: 20,
        color: Colors.green,
      ),
      const SubjectProgress(
        subject: 'Indonesian',
        progress: 0.88,
        grade: 'A',
        completedTopics: 15,
        totalTopics: 17,
        color: Colors.red,
      ),
    ];

    final overallProgress =
        subjects.map((s) => s.progress).reduce((a, b) => a + b) /
        subjects.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.reportProgress),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress Card
            Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Circular Progress
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: overallProgress,
                                strokeWidth: 8,
                                backgroundColor: AppColors.surface.withValues(
                                  alpha: 0.3,
                                ),
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.surface,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(overallProgress * 100).round()}%',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                                Text(
                                  l10n.reportOverall,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: AppColors.textOnPrimary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingL),
                      // Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.reportAcademicProgress,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            Row(
                              children: [
                                _buildStatItem(
                                  l10n.reportSubjects,
                                  '${subjects.length}',
                                ),
                                const SizedBox(width: AppDimensions.paddingL),
                                _buildStatItem(l10n.reportAvgGrade, 'A'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: -0.2, end: 0),
            const SizedBox(height: AppDimensions.paddingXL),
            // Subject Progress
            Text(
              l10n.reportSubjectProgress,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 400),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ...subjects.asMap().entries.map((entry) {
              return _buildSubjectCard(entry.value, entry.key, l10n);
            }),
            const SizedBox(height: AppDimensions.paddingL),
            // Achievements Section
            Text(
              l10n.reportAchievements,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Expanded(
                  child: _buildAchievementCard(
                    icon: Iconsax.medal_star,
                    title: l10n.reportTopPerformer,
                    subtitle: 'Biology',
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: _buildAchievementCard(
                    icon: Iconsax.trend_up,
                    title: l10n.reportMostImproved,
                    subtitle: 'Chemistry',
                    color: AppColors.success,
                  ),
                ),
              ],
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(
    SubjectProgress subject,
    int index,
    AppLocalizations l10n,
  ) {
    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: subject.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          subject.subject[0],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: subject.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.subject,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${subject.completedTopics}/${subject.totalTopics} ${l10n.reportTopics}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: subject.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        subject.grade,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: subject.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: subject.progress,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation(subject.color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Text(
                      '${(subject.progress * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index + 300),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
