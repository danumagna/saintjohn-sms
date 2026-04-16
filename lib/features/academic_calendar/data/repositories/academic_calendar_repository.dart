import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/academic_calendar_entry.dart';

class AcademicCalendarRepository {
  final ApiClient _apiClient;

  AcademicCalendarRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<AcademicCalendarEntry>> getParentCalendar({
    required String id,
    required String loginType,
    required String nidStudent,
    required String authToken,
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final response = await _apiClient.post(
        ApiEndpoints.parentCalendar,
        data: <String, dynamic>{
          'id': id,
          'login_type': loginType,
          'nid_student': nidStudent,
        },
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const AcademicCalendarException('Invalid server response');
      }

      final status = payload['status']?.toString() ?? '0';
      if (status != '1') {
        throw AcademicCalendarException(_extractErrorMessage(payload));
      }

      final data = payload['data'];
      if (data is! List) {
        return <AcademicCalendarEntry>[];
      }

      return data
          .whereType<Map>()
          .map(
            (e) => AcademicCalendarEntry.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AcademicCalendarException(
          'Connection timeout. Please try again.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const AcademicCalendarException(
          'No internet connection. Please check your network.',
        );
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw AcademicCalendarException(_extractErrorMessage(data));
      }

      throw AcademicCalendarException(
        'Failed to load academic calendar: ${e.message}',
      );
    } catch (e) {
      if (e is AcademicCalendarException) {
        rethrow;
      }

      throw AcademicCalendarException('An unexpected error occurred: $e');
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

    return 'Failed to load academic calendar';
  }
}

class AcademicCalendarException implements Exception {
  final String message;

  const AcademicCalendarException(this.message);

  @override
  String toString() => message;
}
