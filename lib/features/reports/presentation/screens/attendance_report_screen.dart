import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../data/models/attendance_chart_data.dart';
import '../../providers/attendance_report_provider.dart';

/// Attendance Report screen.
class AttendanceReportScreen extends ConsumerStatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  ConsumerState<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState
    extends ConsumerState<AttendanceReportScreen> {
  @override
  Widget build(BuildContext context) {
    final request = _buildRequest();
    final chartAsync = request == null
        ? null
        : ref.watch(attendanceChartProvider(request));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Attendance Report'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: request == null
                ? null
                : () => ref.invalidate(attendanceChartProvider(request)),
          ),
        ],
      ),
      body: request == null
          ? _buildInfoState(
              'Student attendance data is not available for this account.',
            )
          : chartAsync!.when(
              loading: _buildLoadingState,
              error: (error, _) => _buildErrorState(
                message: _sanitizeErrorMessage(error),
                onRetry: () => ref.invalidate(attendanceChartProvider(request)),
              ),
              data: _buildDataState,
            ),
    );
  }

  AttendanceReportRequest? _buildRequest() {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return null;
    }

    final nidUser = int.tryParse(user.id);
    final nidStudent =
        user.studentId ??
        user.childrenStudentId?.cast<int?>().firstWhere(
          (id) => (id ?? 0) > 0,
          orElse: () => null,
        );

    if ((nidUser ?? 0) <= 0 || (nidStudent ?? 0) <= 0) {
      return null;
    }

    return AttendanceReportRequest(nidUser: nidUser!, nidStudent: nidStudent!);
  }

  Widget _buildDataState(AttendanceChartData chart) {
    final attendanceRate = chart.attendanceRate.toStringAsFixed(1);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final request = _buildRequest();
        if (request == null) {
          return;
        }
        ref.invalidate(attendanceChartProvider(request));
        await ref.read(attendanceChartProvider(request).future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
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
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      'Total Records: ${chart.totalRecords}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: -0.2, end: 0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
            ),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.paddingM,
              mainAxisSpacing: AppDimensions.paddingM,
              childAspectRatio: 1.7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSummaryTile(
                  label: 'Present',
                  count: chart.present,
                  color: AppColors.success,
                  icon: Iconsax.tick_circle,
                ),
                _buildSummaryTile(
                  label: 'Absent',
                  count: chart.absent,
                  color: AppColors.error,
                  icon: Iconsax.close_circle,
                ),
                _buildSummaryTile(
                  label: 'Sick',
                  count: chart.sick,
                  color: AppColors.warning,
                  icon: Iconsax.activity,
                ),
                _buildSummaryTile(
                  label: 'On Leave',
                  count: chart.onLeave,
                  color: AppColors.info,
                  icon: Iconsax.note,
                ),
              ],
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: AppDimensions.paddingL),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.paddingM,
          mainAxisSpacing: AppDimensions.paddingM,
          childAspectRatio: 1.7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List<Widget>.generate(4, (index) {
            return Shimmer.fromColors(
              baseColor: AppColors.border,
              highlightColor: AppColors.surface,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInfoState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  String _sanitizeErrorMessage(Object error) {
    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'Failed to load attendance report.';
    }
    return text;
  }
}
