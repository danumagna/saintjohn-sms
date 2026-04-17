import 'dart:convert';

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

  /// Apply auth token for subsequent repository requests.
  void setAuthToken(String token) {
    if (token.trim().isEmpty) {
      return;
    }
    _apiClient.setAuthToken(token);
  }

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

  /// Get student dashboard profile data.
  Future<Map<String, String>> getStudentDashboardProfile({
    required int studentRegistrationId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.dashboardStudentProfile,
        queryParameters: <String, dynamic>{
          'nstudentRegistrationId': studentRegistrationId,
        },
        data: <String, dynamic>{
          'nstudentRegistrationId': studentRegistrationId,
        },
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const AuthException('Invalid server response');
      }

      final status = payload['status']?.toString() ?? '0';
      if (status != '1') {
        final message = _extractPayloadMessage(payload);
        if (message != null && message.isNotEmpty) {
          throw AuthException(message);
        }
        throw const AuthException('Failed to get student profile data');
      }

      final data = payload['data'];
      if (data is! List ||
          data.isEmpty ||
          data.first is! Map<String, dynamic>) {
        throw const AuthException('Student profile data not found');
      }

      final source = data.first as Map<String, dynamic>;

      return <String, String>{
        'photoUrl': _normalizeProfilePhotoUrl(
          _readString(source, const [
            'vstudentDashboardProfilePicture',
            'student_picture',
            'profile_picture',
          ]),
        ),
        'name': _readString(source, const [
          'name',
          'vstudentDashboardProfileName',
          'vstudentProfileFullName',
          'full_name',
        ]),
        'email': _readString(source, const [
          'vstudentDashboardProfileEmail',
          'email',
        ]),
        'className': _readStringLoose(
          source,
          const [
            'class_name',
            'vstudentDashboardProfileClassName',
            'className',
            'school_class_name',
            'grade_name',
          ],
          const ['classname', 'class', 'schoolclass', 'grade', 'tingkat'],
        ),
        'schoolName': _readStringLoose(
          source,
          const [
            'school_name',
            'schoolName',
            'vstudentDashboardProfileSchoolName',
            'vSchoolName',
            'v_school_name',
            'unit_school_name',
            'school_unit_name',
          ],
          const [
            'schoolname',
            'school',
            'namasekolah',
            'unitsekolah',
            'schoolunit',
          ],
        ),
        'birthDate': _readString(source, const [
          'birthdate',
          'date_of_birth',
          'dateOfBirth',
        ]),
        'dream': _readString(source, const ['dream']),
        'studentId': _readString(source, const [
          'id_student',
          'student_id',
          'idStudent',
          'studentId',
        ]),
        'classId': _readString(source, const [
          'id_class',
          'class_id',
          'idClass',
          'classId',
        ]),
        'address': _readString(source, const [
          'vstudentDashboardProfileAddress',
          'vstudentDashboardProfileSchoolAddress',
          'address',
        ]),
      };
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

      throw AuthException('Failed to get student profile data: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  /// Get parent profile photo as decoded bytes from Base64 API.
  Future<Uint8List?> getParentProfilePhotoBytes({
    required String parentId,
    int imageIndex = 1,
    int? cacheBust,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.parentProfileFile}/$parentId/$imageIndex',
        queryParameters: cacheBust == null
            ? null
            : <String, dynamic>{'t': cacheBust},
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      final status = payload['status']?.toString();
      if (status != '1') {
        return null;
      }

      final message = payload['message'];
      if (message is! Map<String, dynamic>) {
        return null;
      }

      final encoded = message['file']?.toString().trim() ?? '';
      if (encoded.isEmpty) {
        return null;
      }

      final normalized = _normalizeBase64Payload(encoded);
      return base64Decode(normalized);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }

      if (!kReleaseMode) {
        debugPrint('[parent_profile_photo] failed: ${e.message}');
      }
      return null;
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('[parent_profile_photo] decode failed: $e');
      }
      return null;
    }
  }

  String _normalizeBase64Payload(String value) {
    final trimmed = value.trim();
    final dataMarker = 'base64,';
    final markerIndex = trimmed.indexOf(dataMarker);
    final raw = markerIndex >= 0
        ? trimmed.substring(markerIndex + dataMarker.length)
        : trimmed;

    return raw.replaceAll(RegExp(r'\s+'), '');
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
    final rawPhotoUrl = _readPhotoUrlLoose(source);

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
      'photoUrl': _normalizeProfilePhotoUrl(rawPhotoUrl),
    };
  }

  String _normalizeProfilePhotoUrl(String rawPhotoUrl) {
    final value = rawPhotoUrl.trim().replaceAll('\\', '/');
    if (value.isEmpty) {
      return '';
    }

    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }

    if (lower.startsWith('//')) {
      return 'https:$value';
    }

    final baseUri = Uri.parse('${ApiEndpoints.baseUrl}/');
    final resolved = value.startsWith('/')
        ? Uri.parse(ApiEndpoints.baseUrl).resolve(value)
        : baseUri.resolve(value);
    return resolved.toString();
  }

  String _readPhotoUrlLoose(Map<String, dynamic> source) {
    const exactKeys = <String>[
      'vparentDashboardProfilePicture',
      'vparentProfileParentPicture',
      'vparentProfileParentPhoto',
      'parent_profile_picture',
      'profile_picture',
      'photoUrl',
      'photo',
      'avatar',
    ];
    const containsKeys = <String>[
      'profilepicture',
      'profilephoto',
      'photourl',
      'photo',
      'avatar',
      'picture',
      'image',
    ];

    String fromDynamic(dynamic value) {
      if (value == null) {
        return '';
      }

      if (value is String) {
        return value.trim();
      }

      if (value is Map<String, dynamic>) {
        final nested = _readString(value, const [
          'url',
          'href',
          'src',
          'path',
          'file',
          'fileUrl',
          'filePath',
          'value',
        ]);
        return nested.trim();
      }

      if (value is List && value.isNotEmpty) {
        return fromDynamic(value.first);
      }

      return value.toString().trim();
    }

    for (final key in exactKeys) {
      if (source.containsKey(key)) {
        final found = fromDynamic(source[key]);
        if (found.isNotEmpty) {
          return found;
        }
      }
    }

    for (final entry in source.entries) {
      final normalizedKey = entry.key.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      final isMatch = containsKeys.any((pattern) {
        final normalizedPattern = pattern.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
        return normalizedKey.contains(normalizedPattern);
      });

      if (!isMatch) {
        continue;
      }

      final found = fromDynamic(entry.value);
      if (found.isNotEmpty) {
        return found;
      }
    }

    return '';
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
    String? profilePhotoPath,
  }) async {
    try {
      final basePayload = <String, dynamic>{
        'vparentProfileParentName': parentName,
        'vparentProfileParentEmail': parentEmail,
        'vparentProfileParentPhone': parentPhone,
        'dparentProfileParentDateOfBirth': parentDateOfBirth,
        'vparentProfileParentPlaceOfBirth': parentPlaceOfBirth,
        'vparentProfileParentAddress': parentAddress,
        'vparentProfileParentNationality': parentNationality,
        'vparentProfileParentReligion': parentReligion,
      };
      final updateResponse = await _apiClient.post(
        '${ApiEndpoints.parentProfileUpdate}/$parentId',
        data: basePayload,
        options: Options(contentType: Headers.jsonContentType),
      );
      final updateMessage = _parseUpdateProfileResponse(updateResponse.data);

      final hasPhoto =
          profilePhotoPath != null && profilePhotoPath.trim().isNotEmpty;
      if (!hasPhoto) {
        return updateMessage;
      }

      final uploadMessage = await _uploadParentProfilePhoto(
        parentId: parentId,
        profilePhotoPath: profilePhotoPath,
      );

      return uploadMessage.isNotEmpty ? uploadMessage : updateMessage;
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

      if (e.response?.statusCode == 404) {
        throw const AuthException('Endpoint profile tidak ditemukan (404).');
      }

      if (e.response?.statusCode == 405) {
        throw const AuthException(
          'Method update/upload profile tidak diizinkan (405).',
        );
      }

      if (e.response?.statusCode == 500) {
        throw const AuthException(
          'Server error (500) saat upload foto profile. Silakan coba lagi.',
        );
      }

      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final message = _extractPayloadMessage(data);
          if (message != null && message.isNotEmpty) {
            throw AuthException(message);
          }
        }
        throw const AuthException(
          'Request upload foto tidak valid (400). Periksa format file dan coba lagi.',
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

  Future<String> _uploadParentProfilePhoto({
    required String parentId,
    required String profilePhotoPath,
  }) async {
    final originalFileName = profilePhotoPath.split(RegExp(r'[\\/]')).last;
    final extension = originalFileName.contains('.')
        ? '.${originalFileName.split('.').last}'
        : '';
    final safeFileName =
        'profile_${parentId}_${DateTime.now().millisecondsSinceEpoch}$extension';

    Response<dynamic> response;
    final commonParams = <String, dynamic>{
      'nid': parentId,
      'vfileCategory': '1',
      'nfileSharing': '1',
    };

    try {
      final formData = FormData.fromMap(<String, dynamic>{
        // Must match backend @RequestPart("file").
        'file': await MultipartFile.fromFile(
          profilePhotoPath,
          filename: safeFileName,
        ),
        // Must match backend @RequestParam names and string types.
        ...commonParams,
      });

      response = await _apiClient.post(
        ApiEndpoints.parentProfileUpload,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode != 500 && statusCode != 400) {
        rethrow;
      }

      // Some gateways parse @RequestParam from query more reliably.
      final fallbackFormData = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          profilePhotoPath,
          filename: safeFileName,
        ),
      });

      response = await _apiClient.post(
        ApiEndpoints.parentProfileUpload,
        data: fallbackFormData,
        queryParameters: commonParams,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    }

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return 'Profile updated successfully';
    }

    final status = payload['status']?.toString();
    if (status == '1') {
      final message = _extractPayloadMessage(payload);
      if (message != null && message.isNotEmpty) {
        return message;
      }
      return 'Profile updated successfully';
    }

    final errorMessage = _extractPayloadMessage(payload);
    if (errorMessage != null && errorMessage.isNotEmpty) {
      throw AuthException(errorMessage);
    }

    throw const AuthException('Failed to upload profile photo');
  }

  String _parseUpdateProfileResponse(dynamic rawPayload) {
    if (rawPayload is! Map<String, dynamic>) {
      throw const AuthException('Invalid server response');
    }

    final nestedStatus =
        (rawPayload['message'] as Map<String, dynamic>?)?['userServiceStatus'];
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

    final status = rawPayload['status']?.toString();
    if (status == '1') {
      return 'Profile updated successfully';
    }

    final message = _extractPayloadMessage(rawPayload);
    if (message != null && message.isNotEmpty) {
      throw AuthException(message);
    }

    throw const AuthException('Failed to update profile');
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
