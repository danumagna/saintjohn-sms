import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Attendance record model.
class AttendanceRecord {
  final DateTime date;
  final String status; // 'present', 'absent', 'late', 'excused'
  final String? note;

  const AttendanceRecord({required this.date, required this.status, this.note});
}

/// Attendance Report screen.
class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  String _selectedMonth = 'March 2026';

  final List<String> _months = [
    'January 2026',
    'February 2026',
    'March 2026',
    'April 2026',
    'May 2026',
  ];

  final List<AttendanceRecord> _records = [
    AttendanceRecord(date: DateTime(2026, 3, 1), status: 'present'),
    AttendanceRecord(date: DateTime(2026, 3, 2), status: 'present'),
    AttendanceRecord(
      date: DateTime(2026, 3, 3),
      status: 'late',
      note: 'Arrived 15 minutes late',
    ),
    AttendanceRecord(date: DateTime(2026, 3, 4), status: 'present'),
    AttendanceRecord(
      date: DateTime(2026, 3, 5),
      status: 'absent',
      note: 'Sick - Doctor appointment',
    ),
    AttendanceRecord(date: DateTime(2026, 3, 8), status: 'present'),
    AttendanceRecord(date: DateTime(2026, 3, 9), status: 'present'),
    AttendanceRecord(
      date: DateTime(2026, 3, 10),
      status: 'excused',
      note: 'Family emergency',
    ),
    AttendanceRecord(date: DateTime(2026, 3, 11), status: 'present'),
    AttendanceRecord(date: DateTime(2026, 3, 12), status: 'present'),
  ];

  @override
  Widget build(BuildContext context) {

    final present = _records.where((r) => r.status == 'present').length;
    final absent = _records.where((r) => r.status == 'absent').length;
    final late = _records.where((r) => r.status == 'late').length;
    final excused = _records.where((r) => r.status == 'excused').length;
    final total = _records.length;
    final attendanceRate = ((present + late) / total * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Attendance Report'),
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
                child: Column(
                  children: [
                    Text(
                      'Attendance Rate',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      '$attendanceRate%',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryChip(
                          'Present',
                          present,
                          AppColors.success,
                        ),
                        _buildSummaryChip(
                          'Absent',
                          absent,
                          AppColors.error,
                        ),
                        _buildSummaryChip(
                          'Late',
                          late,
                          AppColors.warning,
                        ),
                        _buildSummaryChip(
                          'Excused',
                          excused,
                          AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: -0.2, end: 0),
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.calendar,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _months.map((month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(
                          month,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedMonth = value!);
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Records List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
              ),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return _buildRecordCard(record, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(AttendanceRecord record, int index) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.status) {
      case 'present':
        statusColor = AppColors.success;
        statusIcon = Iconsax.tick_circle;
        statusText = 'Present';
        break;
      case 'absent':
        statusColor = AppColors.error;
        statusIcon = Iconsax.close_circle;
        statusText = 'Absent';
        break;
      case 'late':
        statusColor = AppColors.warning;
        statusIcon = Iconsax.clock;
        statusText = 'Late';
        break;
      case 'excused':
        statusColor = AppColors.info;
        statusIcon = Iconsax.info_circle;
        statusText = 'Excused';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Iconsax.minus_cirlce;
        statusText = 'Unknown';
    }

    final dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${record.date.day}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        dayNames[record.date.weekday],
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      if (record.note != null) ...[
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          record.note!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 300),
        )
        .slideX(begin: 0.05, end: 0);
  }
}



