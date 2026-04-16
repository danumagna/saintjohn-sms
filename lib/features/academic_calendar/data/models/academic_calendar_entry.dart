class AcademicCalendarEntry {
  final String code;
  final String name;
  final DateTime dateFrom;
  final DateTime dateEnd;
  final bool isHoliday;
  final int fromEvent;

  const AcademicCalendarEntry({
    required this.code,
    required this.name,
    required this.dateFrom,
    required this.dateEnd,
    required this.isHoliday,
    required this.fromEvent,
  });

  String get type {
    if (isHoliday) {
      return 'holiday';
    }
    if (fromEvent == 1) {
      return 'event';
    }
    return 'event';
  }

  factory AcademicCalendarEntry.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime parseDate(dynamic value) {
      final parsed = DateTime.tryParse(value?.toString() ?? '');
      return parsed ?? DateTime.now();
    }

    final from = parseDate(json['ddate_from']);
    final endRaw = parseDate(json['ddate_end']);
    final end = endRaw.isBefore(from) ? from : endRaw;

    return AcademicCalendarEntry(
      code: json['vcode']?.toString() ?? '',
      name: json['vname']?.toString() ?? '',
      dateFrom: DateTime(from.year, from.month, from.day),
      dateEnd: DateTime(end.year, end.month, end.day),
      isHoliday: parseInt(json['nis_holiday']) == 1,
      fromEvent: parseInt(json['from_event']),
    );
  }
}
