import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';

typedef UnauthorizedSessionHandler = Future<void> Function();

/// API client wrapper for network requests.
class ApiClient {
  static UnauthorizedSessionHandler? _unauthorizedHandler;
  static bool _isUnauthorizedFlowRunning = false;
  static bool _interceptorsInitialized = false;
  static final Dio _sharedDio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final Dio _dio;

  ApiClient() : _dio = _sharedDio {
    _initializeInterceptors();
  }

  static void _initializeInterceptors() {
    if (_interceptorsInitialized) {
      return;
    }

    _sharedDio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          if (ApiClient._isTokenExpiredPayload(response.data)) {
            await _triggerUnauthorizedHandler();
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (ApiClient._isUnauthorizedError(error)) {
            await _triggerUnauthorizedHandler();
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _sharedDio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    _interceptorsInitialized = true;
  }

  /// Registers a callback invoked once when unauthorized responses occur.
  static void registerUnauthorizedHandler(UnauthorizedSessionHandler handler) {
    _unauthorizedHandler = handler;
  }

  static Future<void> _triggerUnauthorizedHandler() async {
    if (_isUnauthorizedFlowRunning) {
      return;
    }

    final handler = _unauthorizedHandler;
    if (handler == null) {
      return;
    }

    _isUnauthorizedFlowRunning = true;
    try {
      await handler();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[unauthorized_handler_error] $error');
      }
    } finally {
      _isUnauthorizedFlowRunning = false;
    }
  }

  static bool _isUnauthorizedError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403 || statusCode == 419) {
      return true;
    }

    return _isTokenExpiredPayload(error.response?.data);
  }

  static bool _isTokenExpiredPayload(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return false;
    }

    final errorText = _extractErrorText(payload).toLowerCase();
    if (errorText.isEmpty) {
      return false;
    }

    final hasTokenKeyword =
        errorText.contains('token') || errorText.contains('authtoken');
    final hasUnauthorizedKeyword =
        errorText.contains('expired') ||
        errorText.contains('invalid') ||
        errorText.contains('unauthor') ||
        errorText.contains('session');

    return hasTokenKeyword && hasUnauthorizedKeyword;
  }

  static String _extractErrorText(Map<String, dynamic> payload) {
    final message = payload['message'];

    if (message is String) {
      return message;
    }

    if (message is Map<String, dynamic>) {
      return <String>[
        message['errmsg']?.toString() ?? '',
        message['msg']?.toString() ?? '',
        message['message']?.toString() ?? '',
      ].join(' ').trim();
    }

    return payload['errmsg']?.toString() ?? '';
  }

  /// Set auth token in headers.
  void setAuthToken(String token) {
    _dio.options.headers['AUTHTOKEN'] = token;
  }

  /// Remove auth token from headers.
  void clearAuthToken() {
    _dio.options.headers.remove('AUTHTOKEN');
  }

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
