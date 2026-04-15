/// Model for a single student schedule item from API.
class StudentScheduleItem {
  final String subjectName;
  final String teacherName;
  final String timeStart;
  final String timeEnd;
  final int day;

  const StudentScheduleItem({
    required this.subjectName,
    required this.teacherName,
    required this.timeStart,
    required this.timeEnd,
    required this.day,
  });

  factory StudentScheduleItem.fromJson(Map<String, dynamic> json) {
    return StudentScheduleItem(
      subjectName: _readString(json, const ['subject_name']),
      teacherName: _readString(json, const ['teacher_name']),
      timeStart: _readString(json, const ['time_start']),
      timeEnd: _readString(json, const ['time_end']),
      day: _readInt(json, const ['day']),
    );
  }

  String get startDisplay => _formatTime(timeStart);
  String get endDisplay => _formatTime(timeEnd);

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return '-';
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  static String _formatTime(String value) {
    if (value.isEmpty || value == '-') {
      return '-';
    }

    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }

    return value;
  }
}
