/// User entity.
class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'parent' or 'student'
  final String? avatarUrl;
  final String? grade; // Only for students
  final String? className; // Only for students
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.grade,
    this.className,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? avatarUrl,
    String? grade,
    String? className,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      grade: grade ?? this.grade,
      className: className ?? this.className,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isParent => role == 'parent';
  bool get isStudent => role == 'student';
}
