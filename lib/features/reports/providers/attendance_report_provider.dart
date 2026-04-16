import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/shared_providers.dart';
import '../data/models/attendance_chart_data.dart';
import '../data/repositories/attendance_report_repository.dart';

class AttendanceReportRequest {
  final int nidUser;
  final int nidStudent;

  const AttendanceReportRequest({
    required this.nidUser,
    required this.nidStudent,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AttendanceReportRequest &&
            runtimeType == other.runtimeType &&
            nidUser == other.nidUser &&
            nidStudent == other.nidStudent;
  }

  @override
  int get hashCode => Object.hash(nidUser, nidStudent);
}

final attendanceReportRepositoryProvider = Provider<AttendanceReportRepository>(
  (ref) {
    return AttendanceReportRepository();
  },
);

final attendanceChartProvider =
    FutureProvider.family<AttendanceChartData, AttendanceReportRequest>((
      ref,
      request,
    ) async {
      final currentUser = ref.read(currentUserProvider);
      final authToken = currentUser?.userToken?.trim() ?? '';

      final repository = ref.read(attendanceReportRepositoryProvider);
      return repository.getAttendanceChart(
        nidUser: request.nidUser,
        nidStudent: request.nidStudent,
        authToken: authToken,
      );
    });
