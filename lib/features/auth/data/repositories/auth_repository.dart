import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

  /// Sign up parent account.
  /// Returns success message on success, throws [AuthException] on failure.
  Future<String> signupParent({
    required String nameParent,
    required String emailParent,
    required String phoneParent,
    required String passwordParent,
  }) async {
    try {
      // Hard gate: signup should not continue if email uniqueness
      // validation fails or detects an existing account.
      await _ensureEmailIsUnique(
        nameParent: nameParent,
        emailParent: emailParent,
        phoneParent: phoneParent,
        passwordParent: passwordParent,
      );

      final response = await _apiClient.post(
        ApiEndpoints.signupParent,
        data: <String, dynamic>{
          'nameParent': nameParent,
          'emailParent': emailParent,
          'phoneParent': phoneParent,
          'passwordParent': passwordParent,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final payload = response.data as Map<String, dynamic>;
        final successMessage = _extractSignupSuccessMessage(payload);
        if (successMessage != null) {
          return successMessage;
        }

        final apiResponse = ApiResponse<dynamic>.fromJson(payload, null);
        if (!apiResponse.isSuccess) {
          throw AuthException(apiResponse.errorMessage ?? 'Sign up failed');
        }

        return apiResponse.successMessage ?? 'Account created successfully!';
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return 'Account created successfully!';
      }

      throw const AuthException('Invalid server response');
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
          if (errorMsg != null && errorMsg.isNotEmpty) {
            throw AuthException(errorMsg);
          }
        }
      }
      throw AuthException('Sign up failed: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<void> _ensureEmailIsUnique({
    required String nameParent,
    required String emailParent,
    required String phoneParent,
    required String passwordParent,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.checkEmailUnique,
        data: <String, dynamic>{
          'nameParent': nameParent,
          'emailParent': emailParent,
          'phoneParent': phoneParent,
          'passwordParent': passwordParent,
        },
      );

      final rawResponse = response.data;
      _debugLogEmailCheck(
        'rawType=${rawResponse.runtimeType}, rawValue=$rawResponse',
      );

      if (rawResponse is! Map<String, dynamic>) {
        final rawText = rawResponse?.toString() ?? '';
        if (_isDuplicateEmailError(rawText)) {
          throw const AuthException(
            'Email sudah terdaftar. Gunakan email lain.',
          );
        }

        _debugLogEmailCheck(
          'non-map response without duplicate indicator; treat as available',
        );
        return;
      }

      final payload = rawResponse;
      final status = payload['status']?.toString() ?? '0';
      final data = payload['data'];
      final messageText = _extractPayloadMessage(payload);
      _debugLogEmailCheck(
        'payload=$payload, status=$status, '
        'dataType=${data.runtimeType}, message=$messageText',
      );

      // Detect duplicate across multiple possible backend response shapes.
      final emailAlreadyUsed = status == '1' && data is List && data.isNotEmpty;
      final duplicateFromMessage =
          messageText != null && _isDuplicateEmailError(messageText);
      _debugLogEmailCheck(
        'decision: emailAlreadyUsed=$emailAlreadyUsed, '
        'duplicateFromMessage=$duplicateFromMessage',
      );

      if (emailAlreadyUsed || duplicateFromMessage) {
        throw const AuthException('Email sudah terdaftar. Gunakan email lain.');
      }
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

      final data = e.response?.data;
      _debugLogEmailCheck('dioExceptionType=${e.type}, responseData=$data');
      if (data is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>?;
        final errorMsg =
            message?['errmsg']?.toString() ??
            message?['msg']?.toString() ??
            message?['message']?.toString();
        if (errorMsg != null && errorMsg.isNotEmpty) {
          if (_isDuplicateEmailError(errorMsg)) {
            throw const AuthException(
              'Email sudah terdaftar. Gunakan email lain.',
            );
          }
          throw AuthException(errorMsg);
        }
      }

      if (data is String && data.isNotEmpty) {
        if (_isDuplicateEmailError(data)) {
          throw const AuthException(
            'Email sudah terdaftar. Gunakan email lain.',
          );
        }
        throw AuthException(data);
      }

      throw AuthException('Email validation failed: ${e.message}');
    }
  }

  bool _isDuplicateEmailError(String message) {
    final text = message.toLowerCase();
    return text.contains('sudah terdaftar') ||
        text.contains('email sudah terdaftar') ||
        text.contains('email telah terdaftar') ||
        text.contains('email sudah ada') ||
        text.contains('sudah digunakan') ||
        text.contains('already registered') ||
        text.contains('already exists') ||
        text.contains('already used') ||
        text.contains('email exists') ||
        text.contains('email sudah digunakan');
  }

  String? _extractPayloadMessage(Map<String, dynamic> payload) {
    final message = payload['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    if (message is Map<String, dynamic>) {
      final text =
          message['errmsg']?.toString() ??
          message['msg']?.toString() ??
          message['message']?.toString();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  void _debugLogEmailCheck(String message) {
    if (!kReleaseMode) {
      debugPrint('[check_email_unique] $message');
    }
  }

  String? _extractSignupSuccessMessage(Map<String, dynamic> payload) {
    final status = payload['status']?.toString();
    if (status == '1') {
      return 'Account created successfully!';
    }

    final message = payload['message'];
    if (message is Map<String, dynamic>) {
      final nested = message['userServiceStatus'];
      if (nested is Map<String, dynamic>) {
        final nestedStatus = nested['status']?.toString();
        if (nestedStatus == '1') {
          final nestedMessage = nested['message'];
          if (nestedMessage is Map<String, dynamic>) {
            final successText =
                nestedMessage['msg']?.toString() ??
                nestedMessage['message']?.toString();
            if (successText != null && successText.isNotEmpty) {
              return successText;
            }
          }

          return 'Account created successfully!';
        }
      }
    }

    return null;
  }

  /// Send forgot password validation email.
  Future<String> sendForgotPasswordValidation({
    required String email,
    required String loginType,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendValidation,
        data: <String, dynamic>{'email': email, 'login_type': loginType},
      );

      if (response.data is! Map<String, dynamic>) {
        throw const AuthException('Invalid server response');
      }

      final payload = response.data as Map<String, dynamic>;
      final status = payload['status']?.toString();
      final message = payload['message'];

      if (status != '1') {
        if (message is Map<String, dynamic>) {
          final errorMsg =
              message['errmsg']?.toString() ??
              message['msg']?.toString() ??
              message['message']?.toString();
          if (errorMsg != null && errorMsg.isNotEmpty) {
            throw AuthException(errorMsg);
          }
        }
        throw const AuthException('Failed to send reset password email');
      }

      if (message is Map<String, dynamic>) {
        final successMsg = message['msg']?.toString();
        if (successMsg != null && successMsg.isNotEmpty) {
          return successMsg;
        }
      }

      return 'Reset password email has been sent';
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

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>?;
        final errorMsg =
            message?['errmsg']?.toString() ??
            message?['msg']?.toString() ??
            message?['message']?.toString();
        if (errorMsg != null && errorMsg.isNotEmpty) {
          throw AuthException(errorMsg);
        }
      }

      throw AuthException('Failed to send reset password email: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  /// Get parent profile detail for edit form prefill.
  Future<Map<String, String>> getParentProfile({
    required String parentId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentProfile,
        queryParameters: <String, dynamic>{'nstudentRegistrationId': parentId},
        data: <String, dynamic>{'nstudentRegistrationId': parentId},
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const AuthException('Invalid server response');
      }

      if (!kReleaseMode) {
        debugPrint('[parent_profile] payload=$payload');
      }

      final source = _extractParentProfileSource(payload);
      if (source == null) {
        throw const AuthException('Profile data not found');
      }

      return _buildParentProfileMap(source);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final fallbackProfile = await _tryGetParentProfileFallback(parentId);
        if (fallbackProfile != null) {
          return fallbackProfile;
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AuthException('Connection timeout. Please try again.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const AuthException(
          'No internet connection. Please check your network.',
        );
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = _extractPayloadMessage(data);
        if (message != null && message.isNotEmpty) {
          throw AuthException(message);
        }
      }

      throw AuthException('Failed to get profile data: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, String>?> _tryGetParentProfileFallback(
    String parentId,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.parentProfileUpdate}/$parentId',
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      if (!kReleaseMode) {
        debugPrint('[parent_profile_fallback] payload=$payload');
      }

      final source = _extractParentProfileSource(payload);
      if (source == null) {
        return null;
      }

      return _buildParentProfileMap(source);
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _buildParentProfileMap(Map<String, dynamic> source) {
    return <String, String>{
      'name': _readStringLoose(
        source,
        const ['vparentProfileParentName', 'parent_name', 'name'],
        const ['parentname', 'fullname', 'nama'],
      ),
      'email': _readStringLoose(
        source,
        const ['vparentProfileParentEmail', 'parent_email', 'email'],
        const ['parentemail', 'email'],
      ),
      'phone': _readStringLoose(
        source,
        const [
          'vparentProfileParentPhone',
          'parent_phone',
          'phone',
          'phoneNumber',
        ],
        const ['parentphone', 'phonenumber', 'telepon', 'hp'],
      ),
      'dateOfBirth': _readStringLoose(
        source,
        const [
          'dparentProfileParentDateOfBirth',
          'parent_date_of_birth',
          'date_of_birth',
        ],
        const ['dateofbirth', 'birthdate', 'tanggallahir'],
      ),
      'placeOfBirth': _readStringLoose(
        source,
        const [
          'vparentProfileParentPlaceOfBirth',
          'parent_place_of_birth',
          'place_of_birth',
        ],
        const ['placeofbirth', 'birthplace', 'tempatlahir'],
      ),
      'address': _readStringLoose(
        source,
        const ['vparentProfileParentAddress', 'parent_address', 'address'],
        const ['parentaddress', 'alamat', 'address'],
      ),
      'nationality': _readStringLoose(
        source,
        const [
          'vparentProfileParentNationality',
          'parent_nationality',
          'nationality',
        ],
        const ['nationality', 'kewarganegaraan'],
      ),
      'religion': _readStringLoose(
        source,
        const ['vparentProfileParentReligion', 'parent_religion', 'religion'],
        const ['religion', 'agama'],
      ),
    };
  }

  Map<String, dynamic>? _extractParentProfileSource(
    Map<String, dynamic> payload,
  ) {
    if (payload.containsKey('vparentProfileParentName')) {
      return payload;
    }

    final message = payload['message'];
    if (message is Map<String, dynamic>) {
      final parent = message['parent'];
      if (parent is Map<String, dynamic>) {
        final parentData = parent['data'];
        if (parentData is Map<String, dynamic>) {
          return parentData;
        }
        if (parentData is List) {
          for (final item in parentData) {
            if (item is Map<String, dynamic> &&
                item['vparentProfileParentName'] != null) {
              return item;
            }
          }
          if (parentData.isNotEmpty &&
              parentData.first is Map<String, dynamic>) {
            return parentData.first as Map<String, dynamic>;
          }
        }
      }
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return data.first as Map<String, dynamic>;
    }

    if (message is Map<String, dynamic>) {
      final nested = message['userServiceStatus'];
      if (nested is Map<String, dynamic>) {
        final nestedData = nested['data'];
        if (nestedData is Map<String, dynamic>) {
          return nestedData;
        }
        if (nestedData is List &&
            nestedData.isNotEmpty &&
            nestedData.first is Map<String, dynamic>) {
          return nestedData.first as Map<String, dynamic>;
        }
      }
    }

    final recursive = _findProfileMap(payload);
    if (recursive != null) {
      return recursive;
    }

    return null;
  }

  String _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key]?.toString();
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  String _readStringLoose(
    Map<String, dynamic> source,
    List<String> exactKeys,
    List<String> containsKeys,
  ) {
    final exact = _readString(source, exactKeys);
    if (exact.isNotEmpty) {
      return exact;
    }

    for (final entry in source.entries) {
      final key = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final value = entry.value?.toString().trim() ?? '';
      if (value.isEmpty) {
        continue;
      }

      final isMatch = containsKeys.any((pattern) {
        final normalizedPattern = pattern.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
        return key.contains(normalizedPattern);
      });

      if (isMatch) {
        return value;
      }
    }

    return '';
  }

  Map<String, dynamic>? _findProfileMap(dynamic node) {
    if (node is Map<String, dynamic>) {
      if (_looksLikeProfileMap(node)) {
        return node;
      }

      for (final value in node.values) {
        final found = _findProfileMap(value);
        if (found != null) {
          return found;
        }
      }
    }

    if (node is List) {
      for (final item in node) {
        final found = _findProfileMap(item);
        if (found != null) {
          return found;
        }
      }
    }

    return null;
  }

  bool _looksLikeProfileMap(Map<String, dynamic> map) {
    final keys = map.keys
        .map((e) => e.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
        .toList();

    final hasName = keys.any((k) => k.contains('parentname') || k == 'name');
    final hasEmail = keys.any((k) => k.contains('parentemail') || k == 'email');
    final hasPhone = keys.any(
      (k) =>
          k.contains('parentphone') ||
          k.contains('phonenumber') ||
          k == 'phone',
    );

    final score = [hasName, hasEmail, hasPhone].where((e) => e).length;
    return score >= 2;
  }

  /// Update parent profile.
  Future<String> updateParentProfile({
    required String parentId,
    required String parentName,
    required String parentEmail,
    required String parentPhone,
    required String parentDateOfBirth,
    required String parentPlaceOfBirth,
    required String parentAddress,
    required String parentNationality,
    required String parentReligion,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.parentProfileUpdate}/$parentId',
        data: <String, dynamic>{
          'vparentProfileParentName': parentName,
          'vparentProfileParentEmail': parentEmail,
          'vparentProfileParentPhone': parentPhone,
          'dparentProfileParentDateOfBirth': parentDateOfBirth,
          'vparentProfileParentPlaceOfBirth': parentPlaceOfBirth,
          'vparentProfileParentAddress': parentAddress,
          'vparentProfileParentNationality': parentNationality,
          'vparentProfileParentReligion': parentReligion,
        },
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const AuthException('Invalid server response');
      }

      final nestedStatus =
          (payload['message'] as Map<String, dynamic>?)?['userServiceStatus'];
      if (nestedStatus is Map<String, dynamic>) {
        final status = nestedStatus['status']?.toString();
        if (status == '1') {
          final nestedMessage = nestedStatus['message'];
          if (nestedMessage is Map<String, dynamic>) {
            final success =
                nestedMessage['msg']?.toString() ??
                nestedMessage['message']?.toString();
            if (success != null && success.isNotEmpty) {
              return success;
            }
          }
          return 'Profile updated successfully';
        }

        final nestedMessage = nestedStatus['message'];
        if (nestedMessage is Map<String, dynamic>) {
          final error =
              nestedMessage['errmsg']?.toString() ??
              nestedMessage['msg']?.toString() ??
              nestedMessage['message']?.toString();
          if (error != null && error.isNotEmpty) {
            throw AuthException(error);
          }
        }
      }

      final status = payload['status']?.toString();
      if (status == '1') {
        return 'Profile updated successfully';
      }

      final message = _extractPayloadMessage(payload);
      if (message != null && message.isNotEmpty) {
        throw AuthException(message);
      }

      throw const AuthException('Failed to update profile');
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

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = _extractPayloadMessage(data);
        if (message != null && message.isNotEmpty) {
          throw AuthException(message);
        }
      }

      throw AuthException('Failed to update profile: ${e.message}');
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
