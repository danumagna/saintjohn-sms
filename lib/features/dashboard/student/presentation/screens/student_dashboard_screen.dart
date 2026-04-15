import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../shared/utils/current_user_session_storage.dart';
import '../../../../../shared/data/dummy/dummy_users.dart';
import '../../../../../shared/providers/shared_providers.dart';
import '../../../../../shared/widgets/avatar/user_profile_avatar.dart';
import '../../../../../shared/widgets/cards/menu_card.dart';
import '../../../../auth/providers/auth_provider.dart';

/// Student dashboard screen.
class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  bool _isProfileSyncInProgress = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_syncStudentProfile);
  }

  Future<void> _syncStudentProfile() async {
    if (_isProfileSyncInProgress) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || !user.isStudent) {
      return;
    }

    final candidateIds = <int>{
      if (user.studentId != null) user.studentId!,
      ...?user.childrenStudentId,
      int.tryParse(user.id) ?? -1,
    }.where((id) => id > 0).toList();

    if (candidateIds.isEmpty) {
      return;
    }

    _isProfileSyncInProgress = true;

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final token = user.userToken?.trim() ?? '';
      if (token.isNotEmpty) {
        authRepository.setAuthToken(token);
      }

      Map<String, String>? profile;
      for (final studentRegistrationId in candidateIds) {
        try {
          profile = await authRepository.getStudentDashboardProfile(
            studentRegistrationId: studentRegistrationId,
          );
          break;
        } on Exception catch (e) {
          if (!kReleaseMode) {
            debugPrint(
              '[student_dashboard_profile] '
              'failed for nstudentRegistrationId=$studentRegistrationId '
              'error=$e',
            );
          }
        }
      }

      if (profile == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      final updatedUser = user.copyWith(
        fullName: profile['name']?.trim().isNotEmpty == true
            ? profile['name']!.trim()
            : user.fullName,
        email: profile['email']?.trim().isNotEmpty == true
            ? profile['email']!.trim()
            : user.email,
        className: profile['className']?.trim().isNotEmpty == true
            ? profile['className']!.trim()
            : user.className,
        schoolName: profile['schoolName']?.trim().isNotEmpty == true
            ? profile['schoolName']!.trim()
            : user.schoolName,
        birthDate: profile['birthDate']?.trim().isNotEmpty == true
            ? profile['birthDate']!.trim()
            : user.birthDate,
        dream: profile['dream']?.trim().isNotEmpty == true
            ? profile['dream']!.trim()
            : user.dream,
        classId: int.tryParse(profile['classId'] ?? '') ?? user.classId,
        studentId: int.tryParse(profile['studentId'] ?? '') ?? user.studentId,
        avatarUrl: profile['photoUrl']?.trim().isNotEmpty == true
            ? profile['photoUrl']!.trim()
            : user.avatarUrl,
      );

      ref.read(currentUserProvider.notifier).state = updatedUser;
      if (profile['photoUrl']?.trim().isNotEmpty == true) {
        ref.read(currentUserPhotoBytesProvider.notifier).state = null;
      }
      await saveCurrentUserSessionIfRemembered(updatedUser);
    } catch (_) {
      // Keep UI resilient; dashboard remains usable with existing state.
    } finally {
      _isProfileSyncInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(currentUserProvider) ?? DummyUsers.getDefaultStudent();
    final firstName = user.fullName.trim().isEmpty
        ? 'Login as Student'
        : user.fullName.trim().split(RegExp(r'\s+')).first;

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
                  UserProfileAvatar(
                        user: user,
                        size: 44,
                        backgroundColor: AppColors.secondary.withValues(
                          alpha: 0.1,
                        ),
                        textColor: AppColors.secondary,
                        fontSize: 18,
                        fallbackLetter: 'S',
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
                              'Welcome, $firstName',
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
                          (user.schoolName?.trim().isNotEmpty ?? false)
                              ? '${user.className ?? 'Login as Student'} • ${user.schoolName!.trim()}'
                              : (user.className ?? 'Login as Student'),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: AppDimensions.paddingS),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildSectionHeader(
                      title: 'Today Summary',
                      icon: Iconsax.chart,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    // Summary Section - 3 rows grid (no scroll)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: AppDimensions.paddingS,
                      mainAxisSpacing: AppDimensions.paddingS,
                      childAspectRatio: 1.45,
                      children: [
                        _buildSummaryChip(
                          icon: Iconsax.chart_2,
                          iconColor: AppColors.secondary,
                          value: '85.5',
                          label: 'Avg. Score',
                          index: 0,
                          onTap: () => context.push(AppRoutes.assessment),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.calendar,
                          iconColor: AppColors.schedule,
                          value: '6',
                          label: 'Classes Today',
                          index: 1,
                          onTap: () => context.push(AppRoutes.schedule),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.calendar_2,
                          iconColor: AppColors.warning,
                          value: '3',
                          label: 'Academic Calendar',
                          index: 2,
                          onTap: () => context.push(AppRoutes.academicCalendar),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.user_tick,
                          iconColor: AppColors.success,
                          value: '95%',
                          label: 'Attendance Rate',
                          index: 3,
                          onTap: () => context.push(AppRoutes.attendanceReport),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.note,
                          iconColor: AppColors.success,
                          value: '2',
                          label: 'Exams Today',
                          index: 4,
                          onTap: () => context.push(AppRoutes.examSchedule),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.clock,
                          iconColor: AppColors.success,
                          value: '4/5',
                          label: 'Sessions Attended',
                          index: 5,
                          onTap: () =>
                              context.push(AppRoutes.sessionAttendance),
                        ),
                        _buildSummaryChip(
                          icon: Iconsax.trend_up,
                          iconColor: AppColors.success,
                          value: '78%',
                          label: 'Overall Progress',
                          index: 6,
                          onTap: () => context.push(AppRoutes.studentProgress),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              _buildSectionHeader(
                title: 'Main Menu',
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
                      title: 'Assessment',
                      icon: Iconsax.chart_2,
                      iconColor: AppColors.secondary,
                      index: 0,
                      onTap: () => context.push(AppRoutes.assessment),
                    ),
                    MenuCard(
                      title: 'Class Schedule',
                      icon: Iconsax.calendar,
                      iconColor: AppColors.schedule,
                      index: 1,
                      onTap: () => context.push(AppRoutes.schedule),
                    ),
                    MenuCard(
                      title: 'Academic Calendar',
                      icon: Iconsax.calendar_2,
                      iconColor: AppColors.warning,
                      index: 2,
                      onTap: () => context.push(AppRoutes.academicCalendar),
                    ),
                    MenuCard(
                      title: 'Reports',
                      icon: Iconsax.document_text,
                      iconColor: AppColors.success,
                      index: 3,
                      onTap: () => _showReportsBottomSheet(context),
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

  void _showReportsBottomSheet(BuildContext context) {
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
              'Reports',
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
              title: 'Student Attendance',
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
              title: 'Today\'s Exam Schedule',
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
              title: 'Session Attendance Today',
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
              title: 'Student Progress',
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
