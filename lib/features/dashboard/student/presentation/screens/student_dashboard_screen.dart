import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../features/academic_calendar/data/repositories/academic_calendar_repository.dart';
import '../../../../../features/reports/data/models/attendance_chart_data.dart';
import '../../../../../features/reports/data/repositories/attendance_report_repository.dart';
import '../../../../../features/schedule/data/repositories/schedule_repository.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../shared/utils/current_user_session_storage.dart';
import '../../../../../shared/data/dummy/dummy_users.dart';
import '../../../../../shared/providers/shared_providers.dart';
import '../../../../../shared/widgets/avatar/user_profile_avatar.dart';
import '../../../../../shared/widgets/cards/menu_card.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../auth/domain/entities/user.dart';

class _TodaySummaryData {
  final String classesToday;
  final String academicCalendar;
  final String attendanceRate;
  final String examsToday;

  const _TodaySummaryData({
    required this.classesToday,
    required this.academicCalendar,
    required this.attendanceRate,
    required this.examsToday,
  });

  factory _TodaySummaryData.empty() {
    return const _TodaySummaryData(
      classesToday: '0',
      academicCalendar: '0',
      attendanceRate: '0%',
      examsToday: '0',
    );
  }
}

class _AssessmentMonitoringSummaryItem {
  final String assessmentTypeName;
  final String statusName;
  final String? score;
  final DateTime? assignDate;
  final DateTime? deadline;

  const _AssessmentMonitoringSummaryItem({
    required this.assessmentTypeName,
    required this.statusName,
    required this.score,
    required this.assignDate,
    required this.deadline,
  });

  factory _AssessmentMonitoringSummaryItem.fromJson(Map<String, dynamic> json) {
    return _AssessmentMonitoringSummaryItem(
      assessmentTypeName: json['assessment_type_name']?.toString().trim() ?? '',
      statusName: json['status_name']?.toString().trim() ?? '',
      score: json['score']?.toString(),
      assignDate: DateTime.tryParse(json['assign_date']?.toString() ?? ''),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
    );
  }
}

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
  DateTime _currentDateTime = DateTime.now();
  Timer? _clockTimer;
  final ApiClient _apiClient = ApiClient();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final AcademicCalendarRepository _calendarRepository =
      AcademicCalendarRepository();
  final AttendanceReportRepository _attendanceRepository =
      AttendanceReportRepository();
  late Future<_TodaySummaryData> _todaySummaryFuture;

  @override
  void initState() {
    super.initState();
    _todaySummaryFuture = _loadTodaySummary();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    Future<void>.microtask(_syncStudentProfile);
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
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

      if (mounted) {
        setState(() {
          _todaySummaryFuture = _loadTodaySummary();
        });
      }
    } catch (_) {
      // Keep UI resilient; dashboard remains usable with existing state.
    } finally {
      _isProfileSyncInProgress = false;
    }
  }

  int? _resolveStudentId(User user) {
    if ((user.studentId ?? 0) > 0) {
      return user.studentId;
    }

    final children = user.childrenStudentId;
    if (children != null) {
      for (final id in children) {
        if (id > 0) {
          return id;
        }
      }
    }

    final parsed = int.tryParse(user.id);
    if ((parsed ?? 0) > 0) {
      return parsed;
    }

    return null;
  }

  int? _resolveNidUser(User user) {
    final parsed = int.tryParse(user.id);
    if ((parsed ?? 0) > 0) {
      return parsed;
    }
    return _resolveStudentId(user);
  }

  String _normalizeCalendarLoginType(String rawRole) {
    final role = rawRole.trim().toLowerCase();
    if (role.contains('parent')) {
      return 'parent';
    }
    if (role.contains('student')) {
      return 'student';
    }
    return role;
  }

  String _resolveCalendarRequestId({
    required User user,
    required String loginType,
    required int studentId,
  }) {
    if (loginType == 'student') {
      return studentId.toString();
    }

    final parsed = int.tryParse(user.id);
    if ((parsed ?? 0) > 0) {
      return parsed.toString();
    }

    return studentId.toString();
  }

  bool _isSameDate(DateTime date, DateTime other) {
    final localDate = date.toLocal();
    final localOther = other.toLocal();
    return localDate.year == localOther.year &&
        localDate.month == localOther.month &&
        localDate.day == localOther.day;
  }

  bool _isExamType(String assessmentTypeName) {
    final normalized = assessmentTypeName.toLowerCase();
    return normalized.contains('exam') ||
        normalized.contains('ujian') ||
        normalized.contains('test');
  }

  Future<List<_AssessmentMonitoringSummaryItem>> _loadAssessmentItems({
    required int studentId,
    required int status,
    required String authToken,
  }) async {
    if (authToken.trim().isNotEmpty) {
      _apiClient.setAuthToken(authToken);
    }

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.assessmentMonitoringStatus,
      data: <String, dynamic>{
        'search': <String, dynamic>{'nid_student': studentId, 'status': status},
      },
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return <_AssessmentMonitoringSummaryItem>[];
    }

    if (payload['status']?.toString() != '1') {
      return <_AssessmentMonitoringSummaryItem>[];
    }

    final rawData = payload['data'];
    if (rawData is! List) {
      return <_AssessmentMonitoringSummaryItem>[];
    }

    return rawData
        .whereType<Map>()
        .map(
          (item) => _AssessmentMonitoringSummaryItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<_TodaySummaryData> _loadTodaySummary() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !user.isStudent) {
      return _TodaySummaryData.empty();
    }

    final studentId = _resolveStudentId(user);
    final nidUser = _resolveNidUser(user);
    if ((studentId ?? 0) <= 0 || (nidUser ?? 0) <= 0) {
      return _TodaySummaryData.empty();
    }
    final resolvedStudentId = studentId!;
    final resolvedNidUser = nidUser!;

    final authToken = user.userToken?.trim() ?? '';
    final today = DateTime.now();

    int examsToday = 0;
    try {
      final statuses = <int>[1, 2, 3, 4];
      final lists = await Future.wait(
        statuses.map(
          (status) => _loadAssessmentItems(
            studentId: resolvedStudentId,
            status: status,
            authToken: authToken,
          ),
        ),
      );

      final allAssessmentItems = lists.expand((items) => items).toList();

      examsToday = allAssessmentItems.where((item) {
        if (!_isExamType(item.assessmentTypeName)) {
          return false;
        }
        final dueDate = item.deadline ?? item.assignDate;
        if (dueDate == null) {
          return false;
        }
        return _isSameDate(dueDate, today);
      }).length;
    } catch (_) {
      // Keep dashboard usable if assessment API is temporarily unavailable.
    }

    int classesToday = 0;
    try {
      final classId = await _scheduleRepository.getClassIdByNidUser(
        nidUser: resolvedNidUser,
        authToken: authToken,
      );
      final scheduleByDay = await _scheduleRepository.getStudentSchedule(
        nidSchoolClass: classId.toString(),
        authToken: authToken,
      );
      final weekday = today.weekday;
      classesToday = scheduleByDay[weekday]?.length ?? 0;
    } catch (_) {
      // Keep default value.
    }

    int calendarCount = 0;
    try {
      final calendarLoginType = _normalizeCalendarLoginType(user.role);
      final calendarRequestId = _resolveCalendarRequestId(
        user: user,
        loginType: calendarLoginType,
        studentId: resolvedStudentId,
      );

      final entries = await _calendarRepository.getParentCalendar(
        id: calendarRequestId,
        loginType: calendarLoginType,
        nidStudent: resolvedStudentId.toString(),
        authToken: authToken,
      );
      final startOfToday = DateTime(today.year, today.month, today.day);
      calendarCount = entries
          .where((entry) => !entry.dateEnd.isBefore(startOfToday))
          .length;
    } catch (_) {
      // Keep default value.
    }

    AttendanceChartData? attendance;
    try {
      attendance = await _attendanceRepository.getAttendanceChart(
        nidUser: resolvedNidUser,
        nidStudent: resolvedStudentId,
        authToken: authToken,
      );
    } catch (_) {
      // Keep default value.
    }

    final attendanceRate =
        '${(attendance?.attendanceRate ?? 0).toStringAsFixed(1)}%';

    return _TodaySummaryData(
      classesToday: '$classesToday',
      academicCalendar: '$calendarCount',
      attendanceRate: attendanceRate,
      examsToday: '$examsToday',
    );
  }

  Widget _buildTodaySummaryGrid() {
    return FutureBuilder<_TodaySummaryData>(
      future: _todaySummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingS,
            mainAxisSpacing: AppDimensions.paddingS,
            childAspectRatio: 1.9,
            children: List<Widget>.generate(
              4,
              (index) => _buildSummaryChipSkeleton(index: index),
            ),
          );
        }

        final summary = snapshot.data ?? _TodaySummaryData.empty();

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.paddingS,
          mainAxisSpacing: AppDimensions.paddingS,
          childAspectRatio: 1.9,
          children: [
            _buildSummaryChip(
              icon: Iconsax.user_tick,
              iconColor: AppColors.success,
              value: summary.attendanceRate,
              label: 'Attendance Rate',
              index: 0,
              onTap: () => context.push(AppRoutes.attendanceReport),
            ),
            _buildSummaryChip(
              icon: Iconsax.note,
              iconColor: AppColors.warning,
              value: summary.examsToday,
              label: 'Exams Today',
              index: 1,
              onTap: () => context.push(AppRoutes.examSchedule),
            ),
            _buildSummaryChip(
              icon: Iconsax.calendar_2,
              iconColor: AppColors.warning,
              value: summary.academicCalendar,
              label: 'Academic Calendar',
              index: 2,
              onTap: () => context.push(AppRoutes.academicCalendar),
            ),
            _buildSummaryChip(
              icon: Iconsax.calendar,
              iconColor: AppColors.schedule,
              value: summary.classesToday,
              label: 'Classes Today',
              index: 3,
              onTap: () => context.push(AppRoutes.schedule),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryChipSkeleton({required int index}) {
    return Shimmer.fromColors(
          baseColor: AppColors.borderLight,
          highlightColor: AppColors.surface,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.borderLight),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingS,
              vertical: 6,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 90,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 120 + (index * 50)),
          duration: const Duration(milliseconds: 250),
        )
        .scale(begin: const Offset(0.96, 0.96));
  }

  Widget _buildCurrentDateTimeInfo() {
    final rawDay = DateFormat('EEEE', 'id_ID').format(_currentDateTime);
    final dayLabel = rawDay.toLowerCase() == 'jumat' ? "Jum'at" : rawDay;
    final dateLabel = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(_currentDateTime);
    final timeLabel = DateFormat('HH:mm:ss').format(_currentDateTime);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            timeLabel,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$dayLabel, $dateLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _todaySummaryFuture = _loadTodaySummary();
    });

    try {
      await _todaySummaryFuture;
    } catch (_) {
      // Keep refresh flow resilient when summary API fails.
    }

    await _syncStudentProfile();
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
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                                  backgroundColor: AppColors.secondary
                                      .withValues(alpha: 0.1),
                                  textColor: AppColors.secondary,
                                  fontSize: 18,
                                  fallbackLetter: 'S',
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 400),
                                )
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
                                        delay: const Duration(
                                          milliseconds: 100,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                      )
                                      .slideX(begin: 0.1, end: 0),
                                  Text(
                                    (user.schoolName?.trim().isNotEmpty ??
                                            false)
                                        ? '${user.className ?? 'Login as Student'} • ${user.schoolName!.trim()}'
                                        : (user.className ??
                                              'Login as Student'),
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
                              onPressed: () =>
                                  context.push(AppRoutes.notifications),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingS,
                                ),
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
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
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
                              _buildCurrentDateTimeInfo(),
                              const SizedBox(height: AppDimensions.paddingS),
                              _buildTodaySummaryGrid(),
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
                        GridView.count(
                          shrinkWrap: true,
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
                              onTap: () =>
                                  context.push(AppRoutes.academicCalendar),
                            ),
                            MenuCard(
                              title: 'Student Attendance',
                              icon: Iconsax.user_tick,
                              iconColor: AppColors.success,
                              index: 3,
                              onTap: () =>
                                  context.push(AppRoutes.attendanceReport),
                            ),
                            MenuCard(
                              title: 'Student Progress',
                              icon: Iconsax.chart_success,
                              iconColor: AppColors.info,
                              index: 4,
                              onTap: () =>
                                  context.push(AppRoutes.studentProgress),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
