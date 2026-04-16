import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../data/models/student_schedule_item.dart';
import '../../providers/schedule_provider.dart';

/// Schedule screen showing class timetable.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedDayIndex = 0;
  late final List<int> _orderedDayIndexes;
  Future<int?>? _resolvedClassIdFuture;
  String? _classResolutionError;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    _orderedDayIndexes = _buildOrderedDayIndexes();
    _resolvedClassIdFuture = _resolveClassId();
  }

  Future<int?> _resolveClassId() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !user.isStudent) {
      return null;
    }

    final candidateNidUsers = <int>{
      if (user.studentId != null) user.studentId!,
      if (int.tryParse(user.id) != null) int.tryParse(user.id)!,
    }.where((id) => id > 0).toList();

    if (candidateNidUsers.isEmpty) {
      return null;
    }

    final token = user.userToken?.trim() ?? '';
    final repository = ref.read(scheduleRepositoryProvider);

    String? lastErrorMessage;
    for (final nidUser in candidateNidUsers) {
      try {
        _classResolutionError = null;
        return await repository.getClassIdByNidUser(
          nidUser: nidUser,
          authToken: token,
        );
      } catch (e) {
        final message = e.toString().trim();
        if (message.isNotEmpty) {
          lastErrorMessage = message;
        }
      }
    }

    _classResolutionError = lastErrorMessage;

    return null;
  }

  void _retryClassIdResolution() {
    setState(() {
      _classResolutionError = null;
      _resolvedClassIdFuture = _resolveClassId();
    });
  }

  List<int> _buildOrderedDayIndexes() {
    final int todayWeekday = DateTime.now().weekday;
    final int todayIndex = todayWeekday >= 1 && todayWeekday <= _days.length
        ? todayWeekday - 1
        : 0;

    return List<int>.generate(
      _days.length,
      (int offset) => (todayIndex + offset) % _days.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int selectedDay = _orderedDayIndexes[_selectedDayIndex] + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Class Schedule'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryClassIdResolution,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(child: _buildClassResolutionBody(selectedDay: selectedDay)),
        ],
      ),
    );
  }

  Widget _buildClassResolutionBody({required int selectedDay}) {
    final classIdFuture = _resolvedClassIdFuture;
    if (classIdFuture == null) {
      return _buildInfoState('Class data is not available.');
    }

    return FutureBuilder<int?>(
      future: classIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildClassLoadingSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorState(
            message: 'Failed to load class data.',
            onRetry: _retryClassIdResolution,
          );
        }

        final resolvedClassId = snapshot.data;
        if (resolvedClassId == null || resolvedClassId <= 0) {
          final errorText = _classResolutionError;
          if (errorText != null && errorText.isNotEmpty) {
            return _buildErrorState(
              message: errorText,
              onRetry: _retryClassIdResolution,
            );
          }
          return _buildInfoState('Class data is not available.');
        }

        return _buildScheduleBody(
          classId: resolvedClassId,
          selectedDay: selectedDay,
        );
      },
    );
  }

  Widget _buildClassLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Card(
            elevation: AppDimensions.elevationS,
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusM),
                        bottomLeft: Radius.circular(AppDimensions.radiusM),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeletonLine(width: 110),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _buildSkeletonLine(width: 170),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _buildSkeletonLine(width: 130),
                          const SizedBox(height: AppDimensions.paddingXS),
                          _buildSkeletonLine(width: 140),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final int dayIndex = _orderedDayIndexes[index];
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
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _days[dayIndex].substring(0, 3),
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
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildScheduleBody({required int classId, required int selectedDay}) {
    final scheduleAsync = ref.watch(studentScheduleProvider(classId));

    return scheduleAsync.when(
      loading: _buildScheduleLoadingSkeleton,
      error: (error, _) => _buildErrorState(
        message: _sanitizeErrorMessage(error),
        onRetry: () => ref.invalidate(studentScheduleProvider(classId)),
      ),
      data: (scheduleByDay) {
        _ensureSelectedDayHasData(scheduleByDay);
        final currentSchedule =
            scheduleByDay[selectedDay] ?? <StudentScheduleItem>[];

        if (currentSchedule.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(studentScheduleProvider(classId));
            await ref.read(studentScheduleProvider(classId).future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: currentSchedule.length,
            itemBuilder: (context, index) {
              final item = currentSchedule[index];
              return _buildScheduleCard(item, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildScheduleLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Card(
            elevation: AppDimensions.elevationS,
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonLine(width: 120),
                  const SizedBox(height: AppDimensions.paddingS),
                  _buildSkeletonLine(width: double.infinity),
                  const SizedBox(height: AppDimensions.paddingS),
                  _buildSkeletonLine(width: 150),
                  const SizedBox(height: AppDimensions.paddingS),
                  _buildSkeletonLine(width: 180),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLine({required double width}) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
    );
  }

  void _ensureSelectedDayHasData(
    Map<int, List<StudentScheduleItem>> scheduleByDay,
  ) {
    if (scheduleByDay.isEmpty) {
      return;
    }

    final selectedDay = _orderedDayIndexes[_selectedDayIndex] + 1;
    final selectedItems = scheduleByDay[selectedDay] ?? <StudentScheduleItem>[];
    if (selectedItems.isNotEmpty) {
      return;
    }

    int? nextIndex;
    for (int i = 0; i < _orderedDayIndexes.length; i++) {
      final day = _orderedDayIndexes[i] + 1;
      final items = scheduleByDay[day] ?? <StudentScheduleItem>[];
      if (items.isNotEmpty) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex == null || nextIndex == _selectedDayIndex) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedDayIndex = nextIndex!;
      });
    });
  }

  String _sanitizeErrorMessage(Object error) {
    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'Failed to load schedule.';
    }
    return text;
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

  Widget _buildScheduleCard(StudentScheduleItem item, int index) {
    final accentColor = _subjectColor(item.subjectName);

    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusM),
                      bottomLeft: Radius.circular(AppDimensions.radiusM),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldRow(
                          label: 'Subject',
                          value: item.subjectName,
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        _buildFieldRow(
                          label: 'Teacher',
                          value: item.teacherName,
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        _buildFieldRow(
                          label: 'Start',
                          value: item.startDisplay,
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        _buildFieldRow(label: 'End', value: item.endDisplay),
                      ],
                    ),
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

  Widget _buildFieldRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
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
    );
  }

  Color _subjectColor(String subjectName) {
    const palette = <Color>[
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.schedule,
    ];

    final hash = subjectName.toLowerCase().hashCode.abs();
    return palette[hash % palette.length];
  }
}
