import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Exam item model.
class ExamItem {
  final String subject;
  final String type;
  final String room;
  final String time;
  final DateTime date;
  final String duration;
  final bool isToday;

  const ExamItem({
    required this.subject,
    required this.type,
    required this.room,
    required this.time,
    required this.date,
    required this.duration,
    this.isToday = false,
  });
}

/// Exam Schedule screen.
class ExamScheduleScreen extends StatelessWidget {
  const ExamScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final today = DateTime.now();

    final exams = [
      ExamItem(
        subject: 'Mathematics',
        type: 'Mid-term Exam',
        room: 'Room 101',
        time: '08:00 - 10:00',
        date: today,
        duration: '2 hours',
        isToday: true,
      ),
      ExamItem(
        subject: 'Physics',
        type: 'Quiz',
        room: 'Lab A',
        time: '11:00 - 11:45',
        date: today,
        duration: '45 minutes',
        isToday: true,
      ),
      ExamItem(
        subject: 'English',
        type: 'Mid-term Exam',
        room: 'Room 205',
        time: '08:00 - 10:00',
        date: today.add(const Duration(days: 1)),
        duration: '2 hours',
      ),
      ExamItem(
        subject: 'Chemistry',
        type: 'Mid-term Exam',
        room: 'Lab B',
        time: '11:00 - 13:00',
        date: today.add(const Duration(days: 1)),
        duration: '2 hours',
      ),
      ExamItem(
        subject: 'Biology',
        type: 'Mid-term Exam',
        room: 'Lab C',
        time: '08:00 - 10:00',
        date: today.add(const Duration(days: 2)),
        duration: '2 hours',
      ),
      ExamItem(
        subject: 'Indonesian',
        type: 'Essay Test',
        room: 'Room 102',
        time: '11:00 - 12:30',
        date: today.add(const Duration(days: 3)),
        duration: '1.5 hours',
      ),
    ];

    final todayExams = exams.where((e) => e.isToday).toList();
    final upcomingExams = exams.where((e) => !e.isToday).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Exam Schedule'),
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
            // Today\'s Exams
            if (todayExams.isNotEmpty) ...[
              Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                          child: const Icon(
                            Iconsax.calendar_1,
                            color: AppColors.textOnPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Exams',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.textOnPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${todayExams.length} ${todayExams.length == 1 ? 'exam' : 'exams'}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textOnPrimary,
                                ),
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
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                'Today\'s Exams',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              ...todayExams.asMap().entries.map((entry) {
                return _buildExamCard(entry.value, entry.key, isToday: true);
              }),
            ],
            // Upcoming Exams
            if (upcomingExams.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                'Upcoming Exams',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              ...upcomingExams.asMap().entries.map((entry) {
                return _buildExamCard(
                  entry.value,
                  entry.key + todayExams.length,
                );
              }),
            ],
            // No Exams
            if (exams.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXL),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.document_text,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    Text(
                      'No exams scheduled',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(ExamItem exam, int index, {bool isToday = false}) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Card(
          elevation: isToday
              ? AppDimensions.elevationM
              : AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            side: isToday
                ? const BorderSide(color: AppColors.primary, width: 1.5)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                // Date Box
                Container(
                  width: 55,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${exam.date.day}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? AppColors.textOnPrimary
                              : AppColors.primary,
                        ),
                      ),
                      Text(
                        monthNames[exam.date.month - 1],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: isToday
                              ? AppColors.textOnPrimary.withValues(alpha: 0.8)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exam.subject,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusXS,
                                ),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exam.type,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.clock,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.time,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          const Icon(
                            Iconsax.location,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.room,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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





