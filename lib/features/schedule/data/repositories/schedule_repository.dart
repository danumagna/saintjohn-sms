import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/student_schedule_item.dart';

/// Repository for schedule API operations.
class ScheduleRepository {
  final ApiClient _apiClient;

  ScheduleRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<int> getClassIdByNidUser({
    required int nidUser,
    required String authToken,
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final response = await _apiClient.post(
        ApiEndpoints.studentDataStudent,
        data: <String, dynamic>{
          'search': <String, dynamic>{'nid_user': nidUser},
        },
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ScheduleException('Invalid student data response');
      }

      final status = responseData['status']?.toString() ?? '0';
      if (status != '1') {
        throw ScheduleException(_extractErrorMessage(responseData));
      }

      final rawData = responseData['data'];
      if (rawData is! List || rawData.isEmpty) {
        throw const ScheduleException('Student data not found');
      }

      for (final item in rawData) {
        if (item is! Map) {
          continue;
        }

        final map = Map<String, dynamic>.from(item);
        final idClass = int.tryParse(map['id_class']?.toString() ?? '');
        if (idClass != null && idClass > 0) {
          return idClass;
        }
      }

      throw const ScheduleException('Student class data is incomplete');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const ScheduleException('Connection timeout. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const ScheduleException(
          'No internet connection. Please check your network.',
        );
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ScheduleException(_extractErrorMessage(data));
      }

      throw ScheduleException('Failed to load student data: ${e.message}');
    } catch (e) {
      if (e is ScheduleException) {
        rethrow;
      }

      throw ScheduleException('An unexpected error occurred: $e');
    }
  }

  Future<Map<int, List<StudentScheduleItem>>> getStudentSchedule({
    required String nidSchoolClass,
    required String authToken,
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final requestAttempts = <Map<String, Object?>>[
        {
          'query': <String, dynamic>{'nid_school_class': nidSchoolClass},
          'data': <String, dynamic>{'nid_school_class': nidSchoolClass},
        },
        {
          'query': null,
          'data': <String, dynamic>{'nid_school_class': nidSchoolClass},
        },
        {
          'query': <String, dynamic>{'nid_school_class': nidSchoolClass},
          'data': null,
        },
      ];

      String? lastError;

      for (final request in requestAttempts) {
        try {
          final response = await _apiClient.post(
            ApiEndpoints.studentSchedule,
            queryParameters: request['query'] as Map<String, dynamic>?,
            data: request['data'],
          );

          return _parseScheduleResponse(response.data);
        } on ScheduleException catch (e) {
          lastError = e.message;
          continue;
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            throw const ScheduleException(
              'Connection timeout. Please try again.',
            );
          }

          if (e.type == DioExceptionType.connectionError) {
            throw const ScheduleException(
              'No internet connection. Please check your network.',
            );
          }

          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            lastError = _extractErrorMessage(data);
          } else {
            lastError = e.message;
          }
        }
      }

      throw ScheduleException(lastError ?? 'Failed to load schedule');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const ScheduleException('Connection timeout. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const ScheduleException(
          'No internet connection. Please check your network.',
        );
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ScheduleException(_extractErrorMessage(data));
      }

      throw ScheduleException('Failed to load schedule: ${e.message}');
    } catch (e) {
      if (e is ScheduleException) {
        rethrow;
      }

      throw ScheduleException('An unexpected error occurred: $e');
    }
  }

  Map<int, List<StudentScheduleItem>> _parseScheduleResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ScheduleException('Invalid schedule response');
    }

    final payload = data;
    final status = payload['status']?.toString() ?? '0';

    if (status != '1') {
      throw ScheduleException(_extractErrorMessage(payload));
    }

    final rawData = payload['data'];
    if (rawData is! List) {
      return <int, List<StudentScheduleItem>>{};
    }

    final grouped = <int, List<StudentScheduleItem>>{};

    for (final rawItem in rawData) {
      if (rawItem is! Map) {
        continue;
      }

      final item = StudentScheduleItem.fromJson(
        Map<String, dynamic>.from(rawItem),
      );

      if (item.day < 1 || item.day > 5) {
        continue;
      }

      grouped.putIfAbsent(item.day, () => <StudentScheduleItem>[]).add(item);
    }

    for (final entries in grouped.values) {
      entries.sort((a, b) => a.timeStart.compareTo(b.timeStart));
    }

    return grouped;
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

    return 'Failed to load schedule';
  }
}

/// Exception for schedule API failures.
class ScheduleException implements Exception {
  final String message;

  const ScheduleException(this.message);

  @override
  String toString() => message;
}
