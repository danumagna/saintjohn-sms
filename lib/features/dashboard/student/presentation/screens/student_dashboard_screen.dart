import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../shared/data/dummy/dummy_users.dart';
import '../../../../../shared/providers/shared_providers.dart';
import '../../../../../shared/widgets/cards/menu_card.dart';

/// Student dashboard screen.
class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user =
        ref.watch(currentUserProvider) ?? DummyUsers.getDefaultStudent();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Column(
            children: [
              // App Bar
              Row(
                children: [
                  // Avatar
                  Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 400))
                      .scale(begin: const Offset(0.5, 0.5)),
                  const SizedBox(width: AppDimensions.paddingM),
                  // Welcome Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                              l10n.dashboardWelcome(
                                user.fullName.split(' ').first,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            )
                            .animate()
                            .fadeIn(
                              delay: const Duration(milliseconds: 100),
                              duration: const Duration(milliseconds: 400),
                            )
                            .slideX(begin: 0.1, end: 0),
                        Text(
                          user.className ?? l10n.authLoginAsStudent,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ).animate().fadeIn(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 400),
                        ),
                      ],
                    ),
                  ),
                  // Notification Icon
                  IconButton(
                    onPressed: () => context.push(AppRoutes.notifications),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                    ),
                    icon: Stack(
                      children: [
                        const Icon(
                          Iconsax.notification,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 400),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildSectionHeader(
                      title: l10n.dashboardSummarySectionTitle,
                      icon: Iconsax.chart,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    // Summary Section - 4+3 Grid (no scroll)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: AppDimensions.paddingS,
                      mainAxisSpacing: AppDimensions.paddingS,
                      childAspectRatio: 1.2,
                      children: [
                        _buildSummaryChip(
                          icon: Iconsax.chart_2,
                          iconColor: AppColors.secondary,
                          value: '85.5',
                          label: l10n.dashboardAverageScore,
                          index: 0,
                          onTap: () => context.push(AppRoutes.assessment),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.calendar,
                          iconColor: AppColors.schedule,
                          value: '6',
                          label: l10n.dashboardClassesToday,
                          index: 1,
                          onTap: () => context.push(AppRoutes.schedule),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.calendar_2,
                          iconColor: AppColors.warning,
                          value: '3',
                          label: l10n.menuAcademicCalendar,
                          index: 2,
                          onTap: () => context.push(AppRoutes.academicCalendar),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.user_tick,
                          iconColor: AppColors.success,
                          value: '95%',
                          label: l10n.dashboardAttendanceRate,
                          index: 3,
                          onTap: () => context.push(AppRoutes.attendanceReport),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.note,
                          iconColor: AppColors.success,
                          value: '2',
                          label: l10n.dashboardExamsToday,
                          index: 4,
                          onTap: () => context.push(AppRoutes.examSchedule),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.clock,
                          iconColor: AppColors.success,
                          value: '4/5',
                          label: l10n.dashboardSessionsAttended,
                          index: 5,
                          onTap: () =>
                              context.push(AppRoutes.sessionAttendance),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.trend_up,
                          iconColor: AppColors.success,
                          value: '78%',
                          label: l10n.dashboardOverallProgress,
                          index: 6,
                          onTap: () => context.push(AppRoutes.studentProgress),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSectionHeader(
                title: l10n.dashboardMainMenuSectionTitle,
                icon: Iconsax.element_4,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              // Menu Grid - 2x2, takes remaining space
              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.paddingM,
                  mainAxisSpacing: AppDimensions.paddingM,
                  childAspectRatio: 1.0,
                  children: [
                    MenuCard(
                      title: l10n.menuAssessment,
                      icon: Iconsax.chart_2,
                      iconColor: AppColors.secondary,
                      index: 0,
                      onTap: () => context.push(AppRoutes.assessment),
                    ),
                    MenuCard(
                      title: l10n.menuSchedule,
                      icon: Iconsax.calendar,
                      iconColor: AppColors.schedule,
                      index: 1,
                      onTap: () => context.push(AppRoutes.schedule),
                    ),
                    MenuCard(
                      title: l10n.menuAcademicCalendar,
                      icon: Iconsax.calendar_2,
                      iconColor: AppColors.warning,
                      index: 2,
                      onTap: () => context.push(AppRoutes.academicCalendar),
                    ),
                    MenuCard(
                      title: l10n.menuReports,
                      icon: Iconsax.document_text,
                      iconColor: AppColors.success,
                      index: 3,
                      onTap: () => _showReportsBottomSheet(context, l10n),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportsBottomSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              l10n.menuReports,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            // Attendance Report
            _buildReportItem(
              context: context,
              icon: Iconsax.user_tick,
              title: l10n.menuAttendance,
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.attendanceReport);
              },
            ),
            // Exam Schedule
            _buildReportItem(
              context: context,
              icon: Iconsax.note,
              title: l10n.menuExamSchedule,
              color: AppColors.warning,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.examSchedule);
              },
            ),
            // Session Attendance
            _buildReportItem(
              context: context,
              icon: Iconsax.clock,
              title: l10n.menuSessionAttendance,
              color: AppColors.info,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.sessionAttendance);
              },
            ),
            // Student Progress
            _buildReportItem(
              context: context,
              icon: Iconsax.trend_up,
              title: l10n.menuStudentProgress,
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.studentProgress);
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSummaryChip({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Ink(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: iconColor.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 12, color: iconColor),
                        const SizedBox(width: 4),
                        Text(
                          value,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + (index * 50)),
          duration: const Duration(milliseconds: 300),
        )
        .scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
