/// Login request model.
class LoginRequest {
  final String email;
  final String password;
  final String loginType; // 'student' or 'parent'

  const LoginRequest({
    required this.email,
    required this.password,
    required this.loginType,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'login_type': loginType};
  }
}
