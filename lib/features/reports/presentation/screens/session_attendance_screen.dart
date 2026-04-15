import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Session attendance item model.
class SessionAttendanceItem {
  final String subject;
  final String session;
  final String time;
  final String status; // 'present', 'absent', 'ongoing', 'upcoming'
  final String teacher;

  const SessionAttendanceItem({
    required this.subject,
    required this.session,
    required this.time,
    required this.status,
    required this.teacher,
  });
}

/// Session Attendance screen showing today\'s class attendance.
class SessionAttendanceScreen extends StatelessWidget {
  const SessionAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final sessions = [
      const SessionAttendanceItem(
        subject: 'Mathematics',
        session: 'Session 1',
        time: '07:30 - 09:00',
        status: 'present',
        teacher: 'Mr. John Smith',
      ),
      const SessionAttendanceItem(
        subject: 'Physics',
        session: 'Session 2',
        time: '09:15 - 10:45',
        status: 'present',
        teacher: 'Mrs. Sarah Johnson',
      ),
      const SessionAttendanceItem(
        subject: 'English',
        session: 'Session 3',
        time: '11:00 - 12:30',
        status: 'ongoing',
        teacher: 'Ms. Emily Brown',
      ),
      const SessionAttendanceItem(
        subject: 'Chemistry',
        session: 'Session 4',
        time: '13:30 - 15:00',
        status: 'upcoming',
        teacher: 'Mr. David Lee',
      ),
    ];

    final attended = sessions.where((s) => s.status == 'present').length;
    final total = sessions.where((s) => s.status != 'upcoming').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Session Attendance'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
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
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Attendance',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textOnPrimary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$attended',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '/$total sessions',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    color: AppColors.textOnPrimary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          total > 0
                              ? '${(attended / total * 100).round()}%'
                              : '0%',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: -0.2, end: 0),
          // Session List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionCard(session, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    SessionAttendanceItem session,
    int index,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    Color cardBorderColor;

    switch (session.status) {
      case 'present':
        statusColor = AppColors.success;
        statusIcon = Iconsax.tick_circle;
        statusText = 'Present';
        cardBorderColor = Colors.transparent;
        break;
      case 'absent':
        statusColor = AppColors.error;
        statusIcon = Iconsax.close_circle;
        statusText = 'Absent';
        cardBorderColor = Colors.transparent;
        break;
      case 'ongoing':
        statusColor = AppColors.info;
        statusIcon = Iconsax.play_circle;
        statusText = 'Ongoing';
        cardBorderColor = AppColors.info;
        break;
      case 'upcoming':
        statusColor = AppColors.textTertiary;
        statusIcon = Iconsax.clock;
        statusText = 'Upcoming';
        cardBorderColor = Colors.transparent;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Iconsax.minus_cirlce;
        statusText = 'Unknown';
        cardBorderColor = Colors.transparent;
    }

    return Card(
          elevation: session.status == 'ongoing'
              ? AppDimensions.elevationM
              : AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            side: BorderSide(
              color: cardBorderColor,
              width: cardBorderColor != Colors.transparent ? 1.5 : 0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                // Session Number
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: session.status == 'ongoing'
                        ? AppColors.info.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: session.status == 'ongoing'
                            ? AppColors.info
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.subject,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: session.status == 'upcoming'
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.clock,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.time,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.user,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.teacher,
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
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
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





