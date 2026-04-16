import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/attendance_chart_data.dart';

class AttendanceReportRepository {
  final ApiClient _apiClient;

  AttendanceReportRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<AttendanceChartData> getAttendanceChart({
    required int nidUser,
    required int nidStudent,
    required String authToken,
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final response = await _apiClient.post(
        ApiEndpoints.attendanceChartData,
        data: <String, dynamic>{
          'search': <String, dynamic>{
            'nid_user': nidUser,
            'nid_student': nidStudent,
          },
        },
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const AttendanceReportException('Invalid server response');
      }

      final status = payload['status']?.toString() ?? '0';
      if (status != '1') {
        throw AttendanceReportException(_extractErrorMessage(payload));
      }

      final data = payload['data'];
      if (data is! List || data.isEmpty) {
        return const AttendanceChartData(
          totalRecords: 0,
          present: 0,
          absent: 0,
          sick: 0,
          onLeave: 0,
        );
      }

      final first = data.first;
      if (first is! Map) {
        throw const AttendanceReportException('Invalid attendance data');
      }

      return AttendanceChartData.fromJson(Map<String, dynamic>.from(first));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AttendanceReportException(
          'Connection timeout. Please try again.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const AttendanceReportException(
          'No internet connection. Please check your network.',
        );
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw AttendanceReportException(_extractErrorMessage(data));
      }

      throw AttendanceReportException(
        'Failed to load attendance report: ${e.message}',
      );
    } catch (e) {
      if (e is AttendanceReportException) {
        rethrow;
      }
      throw AttendanceReportException('An unexpected error occurred: $e');
    }
  }

  String _extractErrorMessage(Map<String, dynamic> payload) {
    final message = payload['message'];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    if (message is Map<String, dynamic>) {
      final text =
          message['errmsg']?.toString() ??
          message['msg']?.toString() ??
          message['message']?.toString();
      if (text != null && text.trim().isNotEmpty) {
        return text.trim();
      }
    }

    return 'Failed to load attendance report';
  }
}

class AttendanceReportException implements Exception {
  final String message;

  const AttendanceReportException(this.message);

  @override
  String toString() => message;
}
