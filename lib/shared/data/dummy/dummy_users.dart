import '../../../features/auth/domain/entities/user.dart';

/// Dummy user data for development and testing.
class DummyUsers {
  DummyUsers._();

  static final List<User> parents = [
    User(
      id: 'parent_001',
      fullName: 'John Doe',
      email: 'john.doe@email.com',
      phone: '+62812345678',
      role: 'parent',
      avatarUrl: null,
      createdAt: DateTime(2024, 1, 15),
    ),
    User(
      id: 'parent_002',
      fullName: 'Jane Smith',
      email: 'jane.smith@email.com',
      phone: '+62823456789',
      role: 'parent',
      avatarUrl: null,
      createdAt: DateTime(2024, 2, 20),
    ),
  ];

  static final List<User> students = [
    User(
      id: 'student_001',
      fullName: 'Michael Doe',
      email: 'michael.doe@student.com',
      phone: '+62834567890',
      role: 'student',
      avatarUrl: null,
      grade: '10',
      className: '10-A',
      createdAt: DateTime(2024, 1, 15),
    ),
    User(
      id: 'student_002',
      fullName: 'Sarah Doe',
      email: 'sarah.doe@student.com',
      phone: '+62845678901',
      role: 'student',
      avatarUrl: null,
      grade: '8',
      className: '8-B',
      createdAt: DateTime(2024, 1, 15),
    ),
    User(
      id: 'student_003',
      fullName: 'Emma Smith',
      email: 'emma.smith@student.com',
      phone: '+62856789012',
      role: 'student',
      avatarUrl: null,
      grade: '11',
      className: '11-C',
      createdAt: DateTime(2024, 2, 20),
    ),
  ];

  static User? findByEmail(String email, String role) {
    final users = role == 'parent' ? parents : students;
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  static User getDefaultParent() => parents.first;
  static User getDefaultStudent() => students.first;
}
