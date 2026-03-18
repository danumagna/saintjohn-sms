import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

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
class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initEvents();
  }

  void _initEvents() {
    // Add sample events
    final sampleEvents = [
      CalendarEvent(
        title: 'Mid-term Exams Begin',
        description: 'Mid-term examination period starts',
        date: DateTime(2026, 3, 15),
        type: 'exam',
        color: AppColors.error,
      ),
      CalendarEvent(
        title: 'Independence Day',
        description: 'National Holiday - School Closed',
        date: DateTime(2026, 3, 17),
        type: 'holiday',
        color: AppColors.success,
      ),
      CalendarEvent(
        title: 'Science Fair',
        description: 'Annual science fair exhibition',
        date: DateTime(2026, 3, 22),
        type: 'event',
        color: AppColors.info,
      ),
      CalendarEvent(
        title: 'Report Card Distribution',
        description: 'Parents meeting and report card distribution',
        date: DateTime(2026, 3, 28),
        type: 'event',
        color: AppColors.warning,
      ),
      CalendarEvent(
        title: 'Assignment Deadline',
        description: 'Physics lab report submission',
        date: DateTime(2026, 3, 20),
        type: 'deadline',
        color: AppColors.secondary,
      ),
      CalendarEvent(
        title: 'Easter Holiday',
        description: 'School closed for Easter',
        date: DateTime(2026, 4, 5),
        type: 'holiday',
        color: AppColors.success,
      ),
    ];

    for (final event in sampleEvents) {
      final dateKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      if (_events[dateKey] == null) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(event);
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.calendarTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Calendar
          Card(
                margin: const EdgeInsets.all(AppDimensions.paddingM),
                elevation: AppDimensions.elevationS,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingS),
                  child: TableCalendar<CalendarEvent>(
                    firstDay: DateTime(2026, 1, 1),
                    lastDay: DateTime(2026, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getEventsForDay,
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
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Holiday', AppColors.success),
                _buildLegendItem('Exam', AppColors.error),
                _buildLegendItem('Event', AppColors.info),
                _buildLegendItem('Deadline', AppColors.warning),
              ],
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Events List
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
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
                          l10n.calendarNoEvents,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(CalendarEvent event, int index) {
    IconData icon;
    switch (event.type) {
      case 'holiday':
        icon = Iconsax.sun_1;
        break;
      case 'exam':
        icon = Iconsax.document_text;
        break;
      case 'deadline':
        icon = Iconsax.timer_1;
        break;
      default:
        icon = Iconsax.calendar_tick;
    }

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
