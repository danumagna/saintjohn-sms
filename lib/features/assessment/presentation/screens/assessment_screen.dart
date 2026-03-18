import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Assessment model for dummy data.
class AssessmentItem {
  final String subject;
  final String type;
  final double score;
  final double maxScore;
  final DateTime date;
  final String grade;

  const AssessmentItem({
    required this.subject,
    required this.type,
    required this.score,
    required this.maxScore,
    required this.date,
    required this.grade,
  });

  double get percentage => (score / maxScore) * 100;
}

/// Assessment screen showing student grades and scores.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AssessmentItem> _assessments = [
    AssessmentItem(
      subject: 'Mathematics',
      type: 'Mid-term Exam',
      score: 85,
      maxScore: 100,
      date: DateTime(2026, 3, 10),
      grade: 'A',
    ),
    AssessmentItem(
      subject: 'English',
      type: 'Quiz 1',
      score: 90,
      maxScore: 100,
      date: DateTime(2026, 3, 8),
      grade: 'A',
    ),
    AssessmentItem(
      subject: 'Physics',
      type: 'Lab Report',
      score: 78,
      maxScore: 100,
      date: DateTime(2026, 3, 5),
      grade: 'B+',
    ),
    AssessmentItem(
      subject: 'Chemistry',
      type: 'Mid-term Exam',
      score: 82,
      maxScore: 100,
      date: DateTime(2026, 3, 12),
      grade: 'A-',
    ),
    AssessmentItem(
      subject: 'Biology',
      type: 'Assignment',
      score: 95,
      maxScore: 100,
      date: DateTime(2026, 3, 3),
      grade: 'A+',
    ),
    AssessmentItem(
      subject: 'Indonesian',
      type: 'Essay',
      score: 88,
      maxScore: 100,
      date: DateTime(2026, 3, 1),
      grade: 'A',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.assessmentTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: l10n.assessmentAll),
            Tab(text: l10n.assessmentExams),
            Tab(text: l10n.assessmentAssignments),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
                margin: const EdgeInsets.all(AppDimensions.paddingM),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(l10n.assessmentAverage, '85.3', 'A'),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                    ),
                    _buildSummaryItem(
                      l10n.assessmentTotal,
                      '${_assessments.length}',
                      '',
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                    ),
                    _buildSummaryItem(l10n.assessmentRank, '5', '/30'),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: -0.2, end: 0),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssessmentList(_assessments),
                _buildAssessmentList(
                  _assessments
                      .where(
                        (a) =>
                            a.type.contains('Exam') || a.type.contains('Quiz'),
                      )
                      .toList(),
                ),
                _buildAssessmentList(
                  _assessments
                      .where(
                        (a) =>
                            a.type.contains('Assignment') ||
                            a.type.contains('Report') ||
                            a.type.contains('Essay'),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String suffix) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
            if (suffix.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssessmentList(List<AssessmentItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'No assessments found',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildAssessmentCard(item, index);
      },
    );
  }

  Widget _buildAssessmentCard(AssessmentItem item, int index) {
    Color getScoreColor() {
      if (item.percentage >= 85) return AppColors.success;
      if (item.percentage >= 70) return AppColors.info;
      if (item.percentage >= 50) return AppColors.warning;
      return AppColors.error;
    }

    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subject,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingXS),
                          Text(
                            item.type,
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
                        color: getScoreColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        item.grade,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: getScoreColor(),
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
                          value: item.percentage / 100,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation(getScoreColor()),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Text(
                      '${item.score.toInt()}/${item.maxScore.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      '${item.date.day}/${item.date.month}/${item.date.year}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
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
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(begin: 0.1, end: 0);
  }
}
