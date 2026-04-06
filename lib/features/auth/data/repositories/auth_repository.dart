import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/user.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

/// Auth repository for authentication operations.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Login user.
  /// Returns [User] on success, throws [AuthException] on failure.
  Future<User> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<List<LoginData>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => LoginData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (!apiResponse.isSuccess) {
        throw AuthException(apiResponse.errorMessage ?? 'Login failed');
      }

      if (apiResponse.data == null || apiResponse.data!.isEmpty) {
        throw const AuthException('No user data returned');
      }

      final loginData = apiResponse.data!.first;

      // Store token in API client for future requests
      _apiClient.setAuthToken(loginData.userToken);

      return loginData.toUser();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AuthException('Connection timeout. Please try again.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const AuthException(
          'No internet connection. Please check your network.',
        );
      }
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'] as Map<String, dynamic>?;
          final errorMsg = message?['errmsg'] as String?;
          if (errorMsg != null) {
            throw AuthException(errorMsg);
          }
        }
      }
      throw AuthException('Login failed: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  /// Logout user.
  void logout() {
    _apiClient.clearAuthToken();
  }
}

/// Auth exception.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
