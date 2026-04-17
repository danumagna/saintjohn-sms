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

      final requestPayload = _buildPrimaryPayload(
        id: id,
        loginType: loginType,
        nidStudent: nidStudent,
      );

      final primaryResult = await _fetchCalendar(payload: requestPayload);
      if (primaryResult.isSuccess) {
        return primaryResult.entries;
      }

      final errorMessage = primaryResult.errorMessage;
      if (!_isAuthenticationDenied(errorMessage)) {
        throw AcademicCalendarException(errorMessage);
      }

      final fallbackPayload = _buildAuthFallbackPayload(
        id: id,
        loginType: loginType,
        nidStudent: nidStudent,
      );
      if (fallbackPayload != null) {
        final fallbackResult = await _fetchCalendar(payload: fallbackPayload);
        if (fallbackResult.isSuccess) {
          return fallbackResult.entries;
        }

        final fallbackMessage = fallbackResult.errorMessage;
        if (!_isAuthenticationDenied(fallbackMessage)) {
          throw AcademicCalendarException(fallbackMessage);
        }
      }

      throw const AcademicCalendarException(
        'Academic calendar is not accessible for this account.',
      );
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

  _CalendarFetchResult _parseCalendarPayload(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return const _CalendarFetchResult.error('Invalid server response');
    }

    final status = payload['status']?.toString() ?? '0';
    if (status != '1') {
      return _CalendarFetchResult.error(_extractErrorMessage(payload));
    }

    final data = payload['data'];
    if (data is! List) {
      return const _CalendarFetchResult.success(<AcademicCalendarEntry>[]);
    }

    final entries = data
        .whereType<Map>()
        .map(
          (e) => AcademicCalendarEntry.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
    return _CalendarFetchResult.success(entries);
  }

  Future<_CalendarFetchResult> _fetchCalendar({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentCalendar,
      data: payload,
    );
    return _parseCalendarPayload(response.data);
  }

  Map<String, dynamic> _buildPrimaryPayload({
    required String id,
    required String loginType,
    required String nidStudent,
  }) {
    final trimmedId = id.trim();
    final trimmedStudentId = nidStudent.trim();
    final normalizedLoginType = _normalizeLoginType(loginType);

    final resolvedId = trimmedId.isNotEmpty ? trimmedId : trimmedStudentId;

    // Contract from backend: for calendar access, use login_type=student when
    // nid_student exists, while id can remain user/parent identifier.
    final resolvedLoginType = trimmedStudentId.isNotEmpty
        ? 'student'
        : (normalizedLoginType == 'student' ? 'student' : 'parent');

    return <String, dynamic>{
      'id': resolvedId,
      'login_type': resolvedLoginType,
      'nid_student': trimmedStudentId,
    };
  }

  Map<String, dynamic>? _buildAuthFallbackPayload({
    required String id,
    required String loginType,
    required String nidStudent,
  }) {
    final trimmedId = id.trim();
    final trimmedLoginType = _normalizeLoginType(loginType);
    final trimmedStudentId = nidStudent.trim();

    if (trimmedStudentId.isEmpty) {
      return null;
    }

    if (trimmedLoginType == 'student') {
      // Fallback 1: keep student mode, switch id to student id when current
      // id is a non-student identifier rejected by backend.
      if (trimmedId.isNotEmpty && trimmedId != trimmedStudentId) {
        return <String, dynamic>{
          'id': trimmedStudentId,
          'login_type': 'student',
          'nid_student': trimmedStudentId,
        };
      }

      // Fallback 2: some environments still require parent login_type.
      return <String, dynamic>{
        'id': trimmedId.isNotEmpty ? trimmedId : trimmedStudentId,
        'login_type': 'parent',
        'nid_student': trimmedStudentId,
      };
    }

    if (trimmedId.isEmpty) {
      return null;
    }

    return <String, dynamic>{
      'id': trimmedId,
      'login_type': 'student',
      'nid_student': trimmedStudentId,
    };
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

class _CalendarFetchResult {
  final List<AcademicCalendarEntry> entries;
  final String errorMessage;
  final bool isSuccess;

  const _CalendarFetchResult._({
    required this.entries,
    required this.errorMessage,
    required this.isSuccess,
  });

  const _CalendarFetchResult.success(List<AcademicCalendarEntry> entries)
    : this._(entries: entries, errorMessage: '', isSuccess: true);

  const _CalendarFetchResult.error(String message)
    : this._(
        entries: const <AcademicCalendarEntry>[],
        errorMessage: message,
        isSuccess: false,
      );
}

class AcademicCalendarException implements Exception {
  final String message;

  const AcademicCalendarException(this.message);

  @override
  String toString() => message;
}
