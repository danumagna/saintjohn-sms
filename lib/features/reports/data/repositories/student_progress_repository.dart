import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/student_progress_graph_score_item.dart';

class StudentProgressRepository {
  final ApiClient _apiClient;

  StudentProgressRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<StudentProgressGraphScoreItem>> getGraphScores({
    required String id,
    required String loginType,
    required String student,
    required String authToken,
  }) async {
    try {
      if (authToken.trim().isNotEmpty) {
        _apiClient.setAuthToken(authToken);
      }

      final response = await _apiClient.post(
        ApiEndpoints.studentDashboardProgressGraphScore,
        data: <String, dynamic>{
          'search': <String, dynamic>{
            'id': id,
            'loginType': loginType,
            'student': student,
          },
        },
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const StudentProgressException('Invalid server response');
      }

      final status = payload['status']?.toString() ?? '0';
      if (status != '1') {
        throw StudentProgressException(_extractErrorMessage(payload));
      }

      final data = payload['data'];
      if (data is! List || data.isEmpty) {
        return <StudentProgressGraphScoreItem>[];
      }

      return data
          .whereType<Map>()
          .map(
            (item) => StudentProgressGraphScoreItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const StudentProgressException(
          'Connection timeout. Please try again.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const StudentProgressException(
          'No internet connection. Please check your network.',
        );
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw StudentProgressException(_extractErrorMessage(data));
      }

      throw StudentProgressException('Failed to load progress: ${e.message}');
    } catch (e) {
      if (e is StudentProgressException) {
        rethrow;
      }

      throw StudentProgressException('An unexpected error occurred: $e');
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

    return 'Failed to load progress data';
  }
}

class StudentProgressException implements Exception {
  final String message;

  const StudentProgressException(this.message);

  @override
  String toString() => message;
}
