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
    return LoginData(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      userToken: json['user_token'] as String? ?? '',
      userTokenExpiry: json['user_token_expiry'] != null
          ? DateTime.tryParse(json['user_token_expiry'].toString())
          : null,
      loginType: json['login_type'] as String? ?? '',
      studentId: json['student_id'] as int?,
      childrenStudentId: (json['children_student_id'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      employeeId: json['employee_id'] as String?,
      nstatus: json['nstatus'] as int?,
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
      createdAt: DateTime.now(),
      userToken: userToken,
      userTokenExpiry: userTokenExpiry,
      studentId: studentId,
      childrenStudentId: childrenStudentId,
    );
  }
}
