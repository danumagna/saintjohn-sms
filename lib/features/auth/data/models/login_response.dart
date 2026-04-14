import '../../domain/entities/user.dart';

/// API response wrapper.
class ApiResponse<T> {
  final String status;
  final Map<String, dynamic>? message;
  final T? data;

  const ApiResponse({required this.status, this.message, this.data});

  bool get isSuccess => status == '1';

  String? get errorMessage => message?['errmsg'] as String?;
  String? get successMessage => message?['msg'] as String?;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      status: json['status']?.toString() ?? '0',
      message: json['message'] as Map<String, dynamic>?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}

/// Login response data.
class LoginData {
  final int id;
  final String username;
  final String email;
  final String name;
  final String? phoneNumber;
  final String userToken;
  final DateTime? userTokenExpiry;
  final String loginType;
  final int? studentId;
  final List<int>? childrenStudentId;
  final String? employeeId;
  final int? nstatus;

  const LoginData({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.userToken,
    this.userTokenExpiry,
    required this.loginType,
    this.studentId,
    this.childrenStudentId,
    this.employeeId,
    this.nstatus,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value == null) {
        return null;
      }
      return int.tryParse(value.toString());
    }

    List<int>? parseIntList(dynamic value) {
      if (value is! List) {
        return null;
      }

      final parsed = value.map(parseInt).whereType<int>().toList();
      return parsed.isEmpty ? null : parsed;
    }

    int? readFirstInt(List<String> keys) {
      for (final key in keys) {
        final parsed = parseInt(json[key]);
        if (parsed != null) {
          return parsed;
        }
      }
      return null;
    }

    List<int>? readFirstIntList(List<String> keys) {
      for (final key in keys) {
        final parsed = parseIntList(json[key]);
        if (parsed != null && parsed.isNotEmpty) {
          return parsed;
        }
      }
      return null;
    }

    String readFirstString(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) {
          return value;
        }
      }
      return '';
    }

    DateTime? readFirstDateTime(List<String> keys) {
      for (final key in keys) {
        final raw = json[key];
        if (raw == null) {
          continue;
        }
        final parsed = DateTime.tryParse(raw.toString());
        if (parsed != null) {
          return parsed;
        }
      }
      return null;
    }

    return LoginData(
      id: parseInt(json['id']) ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      userToken: readFirstString(const [
        'user_token',
        'userToken',
        'token',
        'authToken',
        'authtoken',
      ]),
      userTokenExpiry: readFirstDateTime(const [
        'user_token_expiry',
        'userTokenExpiry',
        'token_expiry',
        'tokenExpiry',
      ]),
      loginType: json['login_type'] as String? ?? '',
      studentId: readFirstInt(const [
        'student_id',
        'studentId',
        'nstudentId',
        'nstudentRegistrationId',
        'student_registration_id',
        'nid_student',
      ]),
      childrenStudentId: readFirstIntList(const [
        'children_student_id',
        'childrenStudentId',
        'nchildrenStudentId',
      ]),
      employeeId: json['employee_id'] as String?,
      nstatus: parseInt(json['nstatus']),
    );
  }

  /// Convert to User entity.
  User toUser() {
    return User(
      id: id.toString(),
      fullName: name,
      email: email,
      phone: phoneNumber ?? '',
      role: loginType,
      avatarUrl: null,
      grade: null,
      className: null,
      birthDate: null,
      dream: null,
      schoolName: null,
      classId: null,
      createdAt: DateTime.now(),
      userToken: userToken,
      userTokenExpiry: userTokenExpiry,
      studentId: studentId,
      childrenStudentId: childrenStudentId,
    );
  }
}
