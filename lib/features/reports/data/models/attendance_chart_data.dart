class AttendanceChartData {
  final int totalRecords;
  final int present;
  final int absent;
  final int sick;
  final int onLeave;

  const AttendanceChartData({
    required this.totalRecords,
    required this.present,
    required this.absent,
    required this.sick,
    required this.onLeave,
  });

  double get attendanceRate {
    if (totalRecords <= 0) {
      return 0;
    }
    return ((present + onLeave) / totalRecords) * 100;
  }

  factory AttendanceChartData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return AttendanceChartData(
      totalRecords: parseInt(json['total_records']),
      sick: parseInt(json['records_sick']),
      onLeave: parseInt(json['records_on_leave']),
      present: parseInt(json['records_present']),
      absent: parseInt(json['records_absent']),
    );
  }
}
