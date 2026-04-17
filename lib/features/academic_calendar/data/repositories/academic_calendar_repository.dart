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
      final trimmedToken = authToken.trim();
      if (trimmedToken.isEmpty) {
        throw const AcademicCalendarException(
          'Session expired. Please login again.',
        );
      }
      _apiClient.setAuthToken(trimmedToken);

      final candidates = _buildRequestCandidates(
        id: id,
        loginType: loginType,
        nidStudent: nidStudent,
      );

      AcademicCalendarException? lastAuthDenied;

      for (final candidate in candidates) {
        final response = await _apiClient.post(
          ApiEndpoints.parentCalendar,
          data: candidate,
        );

        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw const AcademicCalendarException('Invalid server response');
        }

        final status = payload['status']?.toString() ?? '0';
        if (status == '1') {
          final data = payload['data'];
          if (data is! List) {
            return <AcademicCalendarEntry>[];
          }

          return data
              .whereType<Map>()
              .map(
                (e) => AcademicCalendarEntry.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
        }

        final message = _extractErrorMessage(payload);
        if (_isAuthenticationDenied(message)) {
          lastAuthDenied = AcademicCalendarException(message);
          continue;
        }

        throw AcademicCalendarException(message);
      }

      if (lastAuthDenied != null) {
        throw const AcademicCalendarException(
          'Authentication denied for calendar request. '
          'Please relogin and try again.',
        );
      }

      throw const AcademicCalendarException('Failed to load academic calendar');
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

  List<Map<String, dynamic>> _buildRequestCandidates({
    required String id,
    required String loginType,
    required String nidStudent,
  }) {
    final trimmedId = id.trim();
    final trimmedLoginType = _normalizeLoginType(loginType);
    final trimmedStudentId = nidStudent.trim();

    final idCandidates = <String>{
      if (trimmedId.isNotEmpty) trimmedId,
      if (trimmedStudentId.isNotEmpty) trimmedStudentId,
    };

    final studentCandidates = <String>{
      if (trimmedStudentId.isNotEmpty) trimmedStudentId,
      if (trimmedId.isNotEmpty) trimmedId,
    };

    final loginTypeCandidates = <String>{
      if (trimmedLoginType.isNotEmpty) trimmedLoginType,
      'student',
      'parent',
    };

    final candidates = <Map<String, dynamic>>[];
    for (final requestLoginType in loginTypeCandidates) {
      for (final requestId in idCandidates) {
        for (final requestStudentId in studentCandidates) {
          candidates.add(<String, dynamic>{
            'id': requestId,
            'login_type': requestLoginType,
            'nid_student': requestStudentId,
          });
        }
      }
    }

    if (candidates.isEmpty) {
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'id': trimmedId,
          'login_type': trimmedLoginType,
          'nid_student': trimmedStudentId,
        },
      ];
    }

    return candidates;
  }

  String _normalizeLoginType(String rawLoginType) {
    final value = rawLoginType.trim().toLowerCase();
    if (value.contains('parent') ||
        value.contains('orang tua') ||
        value.contains('orangtua') ||
        value.contains('ortu') ||
        value.contains('wali')) {
      return 'parent';
    }
    if (value.contains('student') ||
        value.contains('siswa') ||
        value.contains('murid') ||
        value.contains('pelajar')) {
      return 'student';
    }
    return value;
  }

  bool _isAuthenticationDenied(String message) {
    final text = message.trim().toLowerCase();
    return text.contains('authentication denied') ||
        text.contains('auth denied') ||
        text.contains('unauthorized') ||
        text.contains('forbidden');
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
