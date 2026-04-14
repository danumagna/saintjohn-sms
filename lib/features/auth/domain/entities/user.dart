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
  final String? birthDate; // Only for students
  final String? dream; // Only for students
  final String? schoolName; // Only for students
  final int? classId; // Only for students
  final DateTime createdAt;
  final String? userToken;
  final DateTime? userTokenExpiry;
  final int? studentId;
  final List<int>? childrenStudentId;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.grade,
    this.className,
    this.birthDate,
    this.dream,
    this.schoolName,
    this.classId,
    required this.createdAt,
    this.userToken,
    this.userTokenExpiry,
    this.studentId,
    this.childrenStudentId,
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
    String? birthDate,
    String? dream,
    String? schoolName,
    int? classId,
    DateTime? createdAt,
    String? userToken,
    DateTime? userTokenExpiry,
    int? studentId,
    List<int>? childrenStudentId,
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
      birthDate: birthDate ?? this.birthDate,
      dream: dream ?? this.dream,
      schoolName: schoolName ?? this.schoolName,
      classId: classId ?? this.classId,
      createdAt: createdAt ?? this.createdAt,
      userToken: userToken ?? this.userToken,
      userTokenExpiry: userTokenExpiry ?? this.userTokenExpiry,
      studentId: studentId ?? this.studentId,
      childrenStudentId: childrenStudentId ?? this.childrenStudentId,
    );
  }

  bool get isParent => role == 'parent';
  bool get isStudent => role == 'student';
}
