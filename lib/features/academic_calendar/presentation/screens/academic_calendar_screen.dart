import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../data/models/academic_calendar_entry.dart';
import '../../providers/academic_calendar_provider.dart';

/// Calendar event model.
class CalendarEvent {
  final String title;
  final String description;
  final DateTime date;
  final String type; // 'holiday', 'exam', 'event', 'deadline'
  final Color color;

  const CalendarEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.color,
  });
}

/// Academic Calendar screen.
class AcademicCalendarScreen extends ConsumerStatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  ConsumerState<AcademicCalendarScreen> createState() =>
      _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState
    extends ConsumerState<AcademicCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final request = _buildRequest();
    final calendarAsync = request == null
        ? null
        : ref.watch(parentCalendarProvider(request));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Academic Calendar'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: request == null
                ? null
                : () => ref.invalidate(parentCalendarProvider(request)),
          ),
        ],
      ),
      body: request == null
          ? _buildInfoState(
              'Academic calendar data is not available for this account.',
            )
          : calendarAsync!.when(
              loading: _buildLoadingState,
              error: (error, _) => _buildErrorState(
                message: _sanitizeErrorMessage(error),
                onRetry: () => ref.invalidate(parentCalendarProvider(request)),
              ),
              data: (entries) => _buildDataState(entries: entries),
            ),
    );
  }

  AcademicCalendarRequest? _buildRequest() {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return null;
    }

    final id = _resolveRequestId(user.id, user.studentId);
    final loginType = _normalizeLoginType(user.role);
    final nidStudent = _resolveStudentId(
      user.studentId,
      user.childrenStudentId,
      user.id,
    );

    if (id.isEmpty || loginType.isEmpty || nidStudent.isEmpty) {
      return null;
    }

    return AcademicCalendarRequest(
      id: id,
      loginType: loginType,
      nidStudent: nidStudent,
    );
  }

  String _normalizeLoginType(String rawRole) {
    final role = rawRole.trim().toLowerCase();
    if (role.contains('parent')) {
      return 'parent';
    }
    if (role.contains('student')) {
      return 'student';
    }
    return role;
  }

  String _resolveRequestId(String rawId, int? fallbackStudentId) {
    final parsed = int.tryParse(rawId.trim());
    if ((parsed ?? 0) > 0) {
      return parsed.toString();
    }

    if ((fallbackStudentId ?? 0) > 0) {
      return fallbackStudentId.toString();
    }

    return '';
  }

  String _resolveStudentId(
    int? directStudentId,
    List<int>? childrenStudentIds,
    String rawId,
  ) {
    if ((directStudentId ?? 0) > 0) {
      return directStudentId.toString();
    }

    final firstChild = childrenStudentIds
        ?.where((id) => id > 0)
        .cast<int?>()
        .firstWhere((_) => true, orElse: () => null);
    if ((firstChild ?? 0) > 0) {
      return firstChild.toString();
    }

    final parsed = int.tryParse(rawId.trim());
    if ((parsed ?? 0) > 0) {
      return parsed.toString();
    }

    return '';
  }

  Widget _buildDataState({required List<AcademicCalendarEntry> entries}) {
    final eventsByDay = _mapEntriesToEvents(entries);
    final selectedEvents = _getEventsForDay(
      _selectedDay ?? _focusedDay,
      eventsByDay,
    );
    final bounds = _resolveCalendarBounds(entries);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final request = _buildRequest();
        if (request == null) {
          return;
        }
        ref.invalidate(parentCalendarProvider(request));
        await ref.read(parentCalendarProvider(request).future);
      },
      child: Column(
        children: [
          Card(
                margin: const EdgeInsets.all(AppDimensions.paddingM),
                elevation: AppDimensions.elevationS,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingS),
                  child: TableCalendar<CalendarEvent>(
                    firstDay: bounds.firstDay,
                    lastDay: bounds.lastDay,
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) => _getEventsForDay(day, eventsByDay),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      leftChevronIcon: Icon(
                        Iconsax.arrow_left_2,
                        color: AppColors.primary,
                      ),
                      rightChevronIcon: Icon(
                        Iconsax.arrow_right_3,
                        color: AppColors.primary,
                      ),
                      formatButtonTextStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                      formatButtonDecoration: BoxDecoration(
                        border: Border.fromBorderSide(
                          BorderSide(color: AppColors.primary),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: AppColors.error,
                        fontFamily: 'Inter',
                      ),
                      defaultTextStyle: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      weekendStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: -0.1, end: 0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
            ),
            child: const SizedBox.shrink(),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Expanded(
            child: selectedEvents.isEmpty
                ? _buildInfoState('No events for this day')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return _buildEventCard(event, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<CalendarEvent>> _mapEntriesToEvents(
    List<AcademicCalendarEntry> entries,
  ) {
    final map = <DateTime, List<CalendarEvent>>{};

    for (final entry in entries) {
      var cursor = DateTime(
        entry.dateFrom.year,
        entry.dateFrom.month,
        entry.dateFrom.day,
      );
      final end = DateTime(
        entry.dateEnd.year,
        entry.dateEnd.month,
        entry.dateEnd.day,
      );

      var safetyCounter = 0;
      while (!cursor.isAfter(end) && safetyCounter < 3700) {
        final key = DateTime(cursor.year, cursor.month, cursor.day);
        map
            .putIfAbsent(key, () => <CalendarEvent>[])
            .add(
              CalendarEvent(
                title: entry.name,
                description: _buildEventDescription(entry),
                date: key,
                type: entry.type,
                color: _eventColor(entry.type),
              ),
            );
        cursor = cursor.add(const Duration(days: 1));
        safetyCounter++;
      }
    }

    return map;
  }

  List<CalendarEvent> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<CalendarEvent>> eventsByDay,
  ) {
    final key = DateTime(day.year, day.month, day.day);
    return eventsByDay[key] ?? <CalendarEvent>[];
  }

  _CalendarBounds _resolveCalendarBounds(List<AcademicCalendarEntry> entries) {
    final now = DateTime.now();
    if (entries.isEmpty) {
      return _CalendarBounds(
        firstDay: DateTime(now.year - 1, 1, 1),
        lastDay: DateTime(now.year + 1, 12, 31),
      );
    }

    DateTime minDate = entries.first.dateFrom;
    DateTime maxDate = entries.first.dateEnd;

    for (final entry in entries) {
      if (entry.dateFrom.isBefore(minDate)) {
        minDate = entry.dateFrom;
      }
      if (entry.dateEnd.isAfter(maxDate)) {
        maxDate = entry.dateEnd;
      }
    }

    if (_focusedDay.isBefore(minDate)) {
      minDate = _focusedDay;
    }
    if (_focusedDay.isAfter(maxDate)) {
      maxDate = _focusedDay;
    }

    return _CalendarBounds(firstDay: minDate, lastDay: maxDate);
  }

  String _buildEventDescription(AcademicCalendarEntry entry) {
    if (entry.dateFrom.isAtSameMomentAs(entry.dateEnd)) {
      return 'Date: ${_formatDate(entry.dateFrom)}';
    }

    return 'Date: ${_formatDate(entry.dateFrom)} - ${_formatDate(entry.dateEnd)}';
  }

  String _formatDate(DateTime date) {
    const months = <String>[
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

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }

  Color _eventColor(String type) {
    return AppColors.primary;
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Container(
            height: 380,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.calendar_1,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
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
          ],
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
      return 'Failed to load academic calendar.';
    }
    return text;
  }

  Widget _buildEventCard(CalendarEvent event, int index) {
    const IconData icon = Iconsax.calendar_tick;

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
                height: 80,
                decoration: BoxDecoration(
                  color: event.color,
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
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingS),
                        decoration: BoxDecoration(
                          color: event.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Icon(icon, color: event.color, size: 20),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              event.description,
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

class _CalendarBounds {
  final DateTime firstDay;
  final DateTime lastDay;

  const _CalendarBounds({required this.firstDay, required this.lastDay});
}
