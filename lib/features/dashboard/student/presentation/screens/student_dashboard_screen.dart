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
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                          width: 50,
                          height: 50,
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
                                fontSize: 20,
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
                                  fontSize: 18,
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
                              fontSize: 13,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      icon: Stack(
                        children: [
                          const Icon(
                            Iconsax.notification,
                            color: AppColors.textPrimary,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
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
              ),
            ),
            // Menu Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.paddingM,
                  mainAxisSpacing: AppDimensions.paddingM,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate([
                  // Assessment Menu
                  MenuCard(
                    title: l10n.menuAssessment,
                    icon: Iconsax.chart_2,
                    iconColor: AppColors.primary,
                    index: 0,
                    onTap: () => context.push(AppRoutes.assessment),
                  ),
                  // Schedule Menu
                  MenuCard(
                    title: l10n.menuSchedule,
                    icon: Iconsax.calendar,
                    iconColor: AppColors.info,
                    index: 1,
                    onTap: () => context.push(AppRoutes.schedule),
                  ),
                  // Academic Calendar Menu
                  MenuCard(
                    title: l10n.menuAcademicCalendar,
                    icon: Iconsax.calendar_2,
                    iconColor: AppColors.warning,
                    index: 2,
                    onTap: () => context.push(AppRoutes.academicCalendar),
                  ),
                  // Reports Menu
                  MenuCard(
                    title: l10n.menuReports,
                    icon: Iconsax.document_text,
                    iconColor: AppColors.success,
                    index: 3,
                    onTap: () => _showReportsBottomSheet(context, l10n),
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.paddingXL),
            ),
          ],
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
}
