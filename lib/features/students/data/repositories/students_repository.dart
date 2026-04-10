import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/models/login_response.dart';
import '../../domain/entities/student.dart';
import '../models/student_response_model.dart';

/// Repository for students API operations.
class StudentsRepository {
  final ApiClient _apiClient;

  StudentsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Student>> getParentStudents({
    required String authToken,
    required String familyName,
    required String nidParentUser,
  }) async {
    try {
      _apiClient.setAuthToken(authToken);

      final response = await _apiClient.post(
        ApiEndpoints.parentStudents,
        data: <String, dynamic>{
          'familyName': familyName,
          'nidParentUser': nidParentUser,
        },
      );

      if (response.data is List) {
        return _toStudents(response.data as List<dynamic>);
      }

      if (response.data is! Map<String, dynamic>) {
        throw const StudentsException('Invalid server response');
      }

      final payload = response.data as Map<String, dynamic>;

      final statusText = payload['status']?.toString();
      if (statusText != null && statusText != '1') {
        throw StudentsException(_extractErrorMessage(payload));
      }

      final students = _extractStudentsFromPayload(payload);
      if (students != null) {
        return students;
      }

      // Fallback parser for responses using standard status/message/data wrapper.
      final apiResponse = ApiResponse<List<Student>>.fromJson(payload, (data) {
        if (data is! List) return <Student>[];
        return _toStudents(data);
      });

      if (!apiResponse.isSuccess) {
        throw StudentsException(
          apiResponse.errorMessage ?? 'Failed to load student list',
        );
      }

      return apiResponse.data ?? <Student>[];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const StudentsException('Connection timeout. Please try again.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const StudentsException(
          'No internet connection. Please check your network.',
        );
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>?;
        final errorMsg = message?['errmsg'] as String?;
        if (errorMsg != null && errorMsg.isNotEmpty) {
          throw StudentsException(errorMsg);
        }
      }

      throw StudentsException('Failed to load student list: ${e.message}');
    } catch (e) {
      if (e is StudentsException) rethrow;
      throw StudentsException('An unexpected error occurred: $e');
    }
  }

  List<Student>? _extractStudentsFromPayload(Map<String, dynamic> payload) {
    final directData = payload['data'];
    final fromData = _extractStudentsFromAny(directData);
    if (fromData != null) return fromData;

    return _extractStudentsFromAny(payload);
  }

  List<Student>? _extractStudentsFromAny(dynamic node) {
    if (node is List) {
      return _toStudents(node);
    }

    if (node is! Map<String, dynamic>) {
      return null;
    }

    const listKeys = <String>[
      'students',
      'student_list',
      'studentList',
      'items',
      'rows',
      'result',
      'results',
      'data',
    ];

    for (final key in listKeys) {
      final nested = node[key];
      if (nested is List) {
        return _toStudents(nested);
      }
      if (nested is Map<String, dynamic>) {
        final deep = _extractStudentsFromAny(nested);
        if (deep != null) return deep;
      }
    }

    return null;
  }

  List<Student> _toStudents(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(StudentResponseModel.fromJson)
        .toList();
  }

  String _extractErrorMessage(Map<String, dynamic> data) {
    final message = data['message'];
    if (message is Map<String, dynamic>) {
      final errorMsg = message['errmsg']?.toString().trim() ?? '';
      if (errorMsg.isNotEmpty) return errorMsg;
      final altMessage = message['message']?.toString().trim() ?? '';
      if (altMessage.isNotEmpty) return altMessage;
      final msg = message['msg']?.toString().trim() ?? '';
      if (msg.isNotEmpty) return msg;
    }

    final direct = data['errmsg']?.toString().trim() ?? '';
    if (direct.isNotEmpty) return direct;

    return 'Failed to load student list';
  }
}

class StudentsException implements Exception {
  final String message;

  const StudentsException(this.message);

  @override
  String toString() => message;
}
