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

  Future<List<Student>> getParentCandidates({
    required String authToken,
    required String familyName,
    required String nidParentUser,
  }) async {
    try {
      _apiClient.setAuthToken(authToken);

      final response = await _apiClient.post(
        ApiEndpoints.parentCandidates,
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

      final candidates = _extractStudentsFromPayload(payload);
      if (candidates != null) {
        return candidates;
      }

      final apiResponse = ApiResponse<List<Student>>.fromJson(payload, (data) {
        if (data is! List) return <Student>[];
        return _toStudents(data);
      });

      if (!apiResponse.isSuccess) {
        throw StudentsException(
          apiResponse.errorMessage ?? 'Failed to load candidate list',
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

      throw StudentsException('Failed to load candidate list: ${e.message}');
    } catch (e) {
      if (e is StudentsException) rethrow;
      throw StudentsException('An unexpected error occurred: $e');
    }
  }

  Future<List<MasterOption>> getSchoolUnits({required String authToken}) {
    return _getMasterOptions(
      endpoint: ApiEndpoints.schoolUnits,
      authToken: authToken,
      fallbackError: 'Failed to load school units',
    );
  }

  Future<List<MasterOption>> getSchoolLevels({required String authToken}) {
    return _getMasterOptions(
      endpoint: ApiEndpoints.schoolLevels,
      authToken: authToken,
      fallbackError: 'Failed to load school levels',
    );
  }

  Future<List<MasterOption>> getSchoolGrades({required String authToken}) {
    return _getMasterOptions(
      endpoint: ApiEndpoints.schoolGrades,
      authToken: authToken,
      fallbackError: 'Failed to load school grades',
    );
  }

  Future<List<MasterOption>> getAcademicYears({required String authToken}) {
    return _getMasterOptions(
      endpoint: ApiEndpoints.currentAcademicYear,
      authToken: authToken,
      fallbackError: 'Failed to load academic years',
      nameKeys: const ['name', 'schoolYearName', 'schoolYear', 'academicYear'],
    );
  }

  Future<List<MasterOption>> getPaymentMethods({required String authToken}) {
    return _getMasterOptions(
      endpoint: ApiEndpoints.paymentMethodNonFree,
      authToken: authToken,
      fallbackError: 'Failed to load payment methods',
      nameKeys: const [
        'paymentMethodName',
        'name',
        'paymentMethod',
        'payment_method_name',
      ],
      idKeys: const [
        'id',
        'paymentMethodId',
        'paymentMethod',
        'nidPaymentMethod',
        'nPaymentMethod',
      ],
    );
  }

  Future<double> getRegistrationPrice({
    required String authToken,
    required Map<String, dynamic> payload,
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final response = await _apiClient.post(
        ApiEndpoints.registrationPrice,
        data: payload,
      );

      if (response.data is! Map<String, dynamic>) {
        throw const StudentsException('Invalid registration price response');
      }

      final data = response.data as Map<String, dynamic>;
      final statusText = data['status']?.toString();
      if (statusText != null && statusText != '1') {
        throw StudentsException(_extractErrorMessage(data));
      }

      final values = data['data'];
      if (values is List && values.isNotEmpty) {
        final first = values.first;
        if (first is num) {
          return first.toDouble();
        }
        final parsed = double.tryParse(first.toString());
        if (parsed != null) {
          return parsed;
        }
      }

      throw const StudentsException('Registration price not found');
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw StudentsException(_extractErrorMessage(data));
      }
      throw StudentsException(
        'Failed to load registration price: ${e.message}',
      );
    }
  }

  Future<void> submitStudentRegistration({
    required String authToken,
    required Map<String, dynamic> payload,
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final response = await _apiClient.post(
        ApiEndpoints.addCandidate,
        data: payload,
      );

      if (response.data is! Map<String, dynamic>) {
        throw const StudentsException('Invalid student registration response');
      }

      final data = response.data as Map<String, dynamic>;
      final statusText = data['status']?.toString();
      if (statusText != null && statusText != '1') {
        throw StudentsException(_extractErrorMessage(data));
      }

      final nestedError = _extractRegistrationSubmitError(data['message']);
      if (nestedError != null) {
        throw StudentsException(nestedError);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw StudentsException(_extractErrorMessage(data));
      }
      throw StudentsException(
        'Failed to submit student registration: ${e.message}',
      );
    }
  }

  Future<List<MasterOption>> _getMasterOptions({
    required String endpoint,
    required String authToken,
    required String fallbackError,
    List<String> nameKeys = const ['name'],
    List<String> idKeys = const ['id'],
    List<String> codeKeys = const ['code'],
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final response = await _apiClient.post(
        endpoint,
        data: <String, dynamic>{
          'search': <String, dynamic>{'status': ''},
        },
      );

      if (response.data is! Map<String, dynamic>) {
        throw StudentsException(fallbackError);
      }

      final payload = response.data as Map<String, dynamic>;
      final statusText = payload['status']?.toString();
      if (statusText != null && statusText != '1') {
        throw StudentsException(_extractErrorMessage(payload));
      }

      final data = payload['data'];
      if (data is! List) {
        return <MasterOption>[];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => MasterOption(
              id: _pickInt(item, idKeys),
              name: _pickString(item, nameKeys),
              code: _pickString(item, codeKeys),
            ),
          )
          .where((item) => item.name.isNotEmpty && item.id != null)
          .toList();
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
        throw StudentsException(_extractErrorMessage(data));
      }

      throw StudentsException('$fallbackError: ${e.message}');
    }
  }

  int? _pickInt(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  String _pickString(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
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

  String? _extractRegistrationSubmitError(dynamic message) {
    if (message is! Map<String, dynamic>) {
      return null;
    }

    for (final value in message.values) {
      if (value is! Map<String, dynamic>) {
        continue;
      }

      final statusText = value['status']?.toString();
      if (statusText == '0') {
        return _extractErrorMessage(value);
      }
    }

    return null;
  }
}

class StudentsException implements Exception {
  final String message;

  const StudentsException(this.message);

  @override
  String toString() => message;
}

class MasterOption {
  final int? id;
  final String name;
  final String? code;

  const MasterOption({required this.id, required this.name, this.code});
}
