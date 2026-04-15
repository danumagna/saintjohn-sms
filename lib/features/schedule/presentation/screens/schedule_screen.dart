import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Schedule item model.
class ScheduleItem {
  final String subject;
  final String teacher;
  final String room;
  final String startTime;
  final String endTime;
  final Color color;

  const ScheduleItem({
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}

/// Schedule screen showing class timetable.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayIndex = 0;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  final Map<int, List<ScheduleItem>> _scheduleData = {
    0: [
      // Monday
      ScheduleItem(
        subject: 'Mathematics',
        teacher: 'Mr. John Smith',
        room: 'Room 101',
        startTime: '07:30',
        endTime: '09:00',
        color: Colors.blue,
      ),
      ScheduleItem(
        subject: 'Physics',
        teacher: 'Mrs. Sarah Johnson',
        room: 'Lab A',
        startTime: '09:15',
        endTime: '10:45',
        color: Colors.purple,
      ),
      ScheduleItem(
        subject: 'English',
        teacher: 'Ms. Emily Brown',
        room: 'Room 205',
        startTime: '11:00',
        endTime: '12:30',
        color: Colors.green,
      ),
      ScheduleItem(
        subject: 'Chemistry',
        teacher: 'Mr. David Lee',
        room: 'Lab B',
        startTime: '13:30',
        endTime: '15:00',
        color: Colors.orange,
      ),
    ],
    1: [
      // Tuesday
      ScheduleItem(
        subject: 'Biology',
        teacher: 'Dr. Michael Chen',
        room: 'Lab C',
        startTime: '07:30',
        endTime: '09:00',
        color: Colors.teal,
      ),
      ScheduleItem(
        subject: 'Indonesian',
        teacher: 'Ibu Siti Rahayu',
        room: 'Room 102',
        startTime: '09:15',
        endTime: '10:45',
        color: Colors.red,
      ),
      ScheduleItem(
        subject: 'History',
        teacher: 'Mr. Robert Wilson',
        room: 'Room 301',
        startTime: '11:00',
        endTime: '12:30',
        color: Colors.brown,
      ),
    ],
    2: [
      // Wednesday
      ScheduleItem(
        subject: 'Mathematics',
        teacher: 'Mr. John Smith',
        room: 'Room 101',
        startTime: '07:30',
        endTime: '09:00',
        color: Colors.blue,
      ),
      ScheduleItem(
        subject: 'Art',
        teacher: 'Ms. Lisa Anderson',
        room: 'Art Studio',
        startTime: '09:15',
        endTime: '10:45',
        color: Colors.pink,
      ),
      ScheduleItem(
        subject: 'Physical Education',
        teacher: 'Coach James Taylor',
        room: 'Sports Field',
        startTime: '11:00',
        endTime: '12:30',
        color: Colors.amber,
      ),
      ScheduleItem(
        subject: 'English',
        teacher: 'Ms. Emily Brown',
        room: 'Room 205',
        startTime: '13:30',
        endTime: '15:00',
        color: Colors.green,
      ),
    ],
    3: [
      // Thursday
      ScheduleItem(
        subject: 'Physics',
        teacher: 'Mrs. Sarah Johnson',
        room: 'Lab A',
        startTime: '07:30',
        endTime: '09:00',
        color: Colors.purple,
      ),
      ScheduleItem(
        subject: 'Geography',
        teacher: 'Mr. William Harris',
        room: 'Room 302',
        startTime: '09:15',
        endTime: '10:45',
        color: Colors.cyan,
      ),
      ScheduleItem(
        subject: 'Chemistry',
        teacher: 'Mr. David Lee',
        room: 'Lab B',
        startTime: '11:00',
        endTime: '12:30',
        color: Colors.orange,
      ),
    ],
    4: [
      // Friday
      ScheduleItem(
        subject: 'Biology',
        teacher: 'Dr. Michael Chen',
        room: 'Lab C',
        startTime: '07:30',
        endTime: '09:00',
        color: Colors.teal,
      ),
      ScheduleItem(
        subject: 'Music',
        teacher: 'Mr. Daniel Martin',
        room: 'Music Room',
        startTime: '09:15',
        endTime: '10:45',
        color: Colors.indigo,
      ),
      ScheduleItem(
        subject: 'Religion',
        teacher: 'Father Anthony',
        room: 'Chapel',
        startTime: '11:00',
        endTime: '12:30',
        color: Colors.deepPurple,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentSchedule = _scheduleData[_selectedDayIndex] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Class Schedule'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Day Selector
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingM,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
              ),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  child:
                      Container(
                            width: 65,
                            margin: const EdgeInsets.only(
                              right: AppDimensions.paddingS,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _days[index].substring(0, 3),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.textOnPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                          .animate(target: isSelected ? 1 : 0)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: const Duration(milliseconds: 200),
                          ),
                );
              },
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
          // Schedule List
          Expanded(
            child: currentSchedule.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: currentSchedule.length,
                    itemBuilder: (context, index) {
                      final item = currentSchedule[index];
                      return _buildScheduleCard(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.calendar,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          const Text(
            'No classes scheduled',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item, int index) {
    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 100,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusM),
                    bottomLeft: Radius.circular(AppDimensions.radiusM),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Row(
                    children: [
                      // Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.startTime,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.borderLight,
                          ),
                          Text(
                            item.endTime,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Container(
                        width: 1,
                        height: 60,
                        color: AppColors.borderLight,
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      // Details
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
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.user,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.teacher,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.location,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.room,
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
              ),
            ],
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



