import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/utils/current_user_session_storage.dart';
import '../../../auth/domain/entities/user.dart';

/// Exam item model.
class ExamItem {
  final String subject;
  final String type;
  final String status;
  final String time;
  final DateTime date;
  final DateTime? assignDate;
  final DateTime? deadline;
  final String duration;
  final bool isToday;

  const ExamItem({
    required this.subject,
    required this.type,
    required this.status,
    required this.time,
    required this.date,
    required this.assignDate,
    required this.deadline,
    required this.duration,
    this.isToday = false,
  });
}

class _AssessmentMonitoringSummaryItem {
  final String subjectName;
  final String assessmentTypeName;
  final DateTime? assignDate;
  final DateTime? deadline;
  final String statusName;

  const _AssessmentMonitoringSummaryItem({
    required this.subjectName,
    required this.assessmentTypeName,
    required this.assignDate,
    required this.deadline,
    required this.statusName,
  });

  factory _AssessmentMonitoringSummaryItem.fromJson(Map<String, dynamic> json) {
    return _AssessmentMonitoringSummaryItem(
      subjectName: json['subject_name']?.toString().trim() ?? '-',
      assessmentTypeName:
          json['assessment_type_name']?.toString().trim() ?? '-',
      assignDate: DateTime.tryParse(json['assign_date']?.toString() ?? ''),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      statusName: json['status_name']?.toString().trim() ?? '-',
    );
  }
}

/// Exam Schedule screen.
class ExamScheduleScreen extends ConsumerStatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  ConsumerState<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends ConsumerState<ExamScheduleScreen> {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  List<ExamItem> _exams = <ExamItem>[];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadExamSchedule);
  }

  int? _resolveStudentId(User? user) {
    if (user == null) {
      return null;
    }

    final directStudentId = user.studentId;
    if (directStudentId != null && directStudentId > 0) {
      return directStudentId;
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

  String _extractPayloadMessage(Map<String, dynamic> payload) {
    final message = payload['message'];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    if (message is Map<String, dynamic>) {
      final error = message['errmsg']?.toString().trim();
      final msg = message['msg']?.toString().trim();
      final detail = message['message']?.toString().trim();

      if (error != null && error.isNotEmpty) {
        return error;
      }
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }
    }

    return 'Failed to load exam schedule';
  }

  bool _isSameDate(DateTime date, DateTime other) {
    final a = date.toLocal();
    final b = other.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isAfterDateOnly(DateTime date, DateTime base) {
    final a = DateTime(date.year, date.month, date.day);
    final b = DateTime(base.year, base.month, base.day);
    return a.isAfter(b);
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatTimeOfDay(DateTime dateTime) {
    return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _buildTimeLabel(DateTime? assignDate, DateTime? deadline) {
    if (assignDate == null && deadline == null) {
      return '-';
    }

    if (assignDate != null && deadline != null) {
      return '${_formatTimeOfDay(assignDate)} - ${_formatTimeOfDay(deadline)}';
    }

    final reference = assignDate ?? deadline;
    return reference == null ? '-' : _formatTimeOfDay(reference);
  }

  String _buildDurationLabel(DateTime? assignDate, DateTime? deadline) {
    if (assignDate == null || deadline == null) {
      return '-';
    }

    final minutes = deadline.difference(assignDate).inMinutes;
    if (minutes <= 0) {
      return '-';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes minutes';
    }

    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }

    return '$hours h $remainingMinutes min';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final local = value.toLocal();
    return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExamDetail(ExamItem exam) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusL),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingL,
                AppDimensions.paddingM,
                AppDimensions.paddingL,
                AppDimensions.paddingL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXS,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  const Text(
                    'Exam Detail',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _buildDetailRow(label: 'Subject', value: exam.subject),
                  _buildDetailRow(label: 'Type', value: exam.type),
                  _buildDetailRow(label: 'Status', value: exam.status),
                  _buildDetailRow(label: 'Time', value: exam.time),
                  _buildDetailRow(
                    label: 'Assign Date',
                    value: _formatDateTime(exam.assignDate),
                  ),
                  _buildDetailRow(
                    label: 'Deadline',
                    value: _formatDateTime(exam.deadline),
                  ),
                  _buildDetailRow(label: 'Duration', value: exam.duration),
                  const SizedBox(height: AppDimensions.paddingS),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<_AssessmentMonitoringSummaryItem>> _loadAssessmentItems({
    required int studentId,
    required int status,
  }) async {
    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.assessmentMonitoringStatus,
      data: <String, dynamic>{
        'search': <String, dynamic>{'nid_student': studentId, 'status': status},
      },
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw StateError('Invalid exam schedule response');
    }

    if (payload['status']?.toString() != '1') {
      throw StateError(_extractPayloadMessage(payload));
    }

    final data = payload['data'];
    if (data is! List) {
      return <_AssessmentMonitoringSummaryItem>[];
    }

    return data.whereType<Map>().map((item) {
      return _AssessmentMonitoringSummaryItem.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  ExamItem? _toExamItem(_AssessmentMonitoringSummaryItem item, DateTime now) {
    final assignDate = item.assignDate;
    final deadline = item.deadline;
    final isToday =
        (assignDate != null && _isSameDate(assignDate, now)) ||
        (deadline != null && _isSameDate(deadline, now));

    final date = isToday
        ? (assignDate != null && _isSameDate(assignDate, now)
              ? assignDate
              : deadline)
        : (deadline ?? assignDate);
    if (date == null) {
      return null;
    }

    return ExamItem(
      subject: item.subjectName.trim().isEmpty ? '-' : item.subjectName,
      type: item.assessmentTypeName,
      status: item.statusName,
      time: _buildTimeLabel(assignDate, deadline),
      date: date,
      assignDate: assignDate,
      deadline: deadline,
      duration: _buildDurationLabel(assignDate, deadline),
      isToday: isToday,
    );
  }

  Future<void> _loadExamSchedule({bool isRefresh = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      if (isRefresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      User? user = ref.read(currentUserProvider);
      user ??= await readStoredCurrentUser();
      if (user != null && ref.read(currentUserProvider) == null) {
        ref.read(currentUserProvider.notifier).state = user;
      }

      final token = user?.userToken?.trim() ?? '';
      if (token.isNotEmpty) {
        _apiClient.setAuthToken(token);
      }

      final studentId = _resolveStudentId(user);
      if ((studentId ?? 0) <= 0) {
        throw StateError('Student data is unavailable for this account');
      }

      final statuses = <int>[1, 2, 3, 4];
      final results = await Future.wait(
        statuses.map(
          (status) =>
              _loadAssessmentItems(studentId: studentId!, status: status),
        ),
      );

      final now = DateTime.now();
      final items =
          results
              .expand((list) => list)
              .map((entry) => _toExamItem(entry, now))
              .whereType<ExamItem>()
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      if (!mounted) {
        return;
      }

      setState(() {
        _exams = items;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error is StateError
            ? error.message.toString()
            : 'Failed to load exam schedule';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayExams = _exams.where((e) => e.isToday).toList();
    final upcomingExams = _exams
        .where((e) => _isAfterDateOnly(e.date, today))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Exam Schedule'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: (_isLoading || _isRefreshing)
                ? null
                : () => _loadExamSchedule(isRefresh: true),
          ),
        ],
      ),
      body: _isLoading && _exams.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _exams.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 52,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    ElevatedButton(
                      onPressed: _loadExamSchedule,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadExamSchedule(isRefresh: true),
              color: AppColors.primary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today\'s Exams
                    if (todayExams.isNotEmpty) ...[
                      Container(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingM,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusL,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.paddingM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(
                                      alpha: 0.2,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Today\'s Exams',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: AppColors.textOnPrimary
                                              .withValues(alpha: 0.8),
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
                        return _buildExamCard(
                          entry.value,
                          entry.key,
                          isToday: true,
                        );
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
                    if (_exams.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 100),
                            Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingXL,
                              ),
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
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            onTap: () => _showExamDetail(exam),
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
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
                                  color: AppColors.warning.withValues(
                                    alpha: 0.1,
                                  ),
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
                              Iconsax.info_circle,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exam.status,
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
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(begin: 0.1, end: 0);
  }
}
