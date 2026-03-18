import '../../../features/students/domain/entities/student.dart';

/// Dummy student data for development and testing.
class DummyStudents {
  DummyStudents._();

  static final List<Student> students = [
    Student(
      id: 'std_001',
      fullName: 'Michael Doe',
      nisn: '0012345678',
      grade: '10',
      className: '10-A',
      gender: 'Male',
      birthDate: DateTime(2009, 5, 15),
      birthPlace: 'Jakarta',
      address: 'Jl. Sudirman No. 123, Jakarta',
      parentId: 'parent_001',
      createdAt: DateTime(2024, 1, 15),
    ),
    Student(
      id: 'std_002',
      fullName: 'Sarah Doe',
      nisn: '0012345679',
      grade: '8',
      className: '8-B',
      gender: 'Female',
      birthDate: DateTime(2011, 8, 22),
      birthPlace: 'Bandung',
      address: 'Jl. Sudirman No. 123, Jakarta',
      parentId: 'parent_001',
      createdAt: DateTime(2024, 1, 15),
    ),
    Student(
      id: 'std_003',
      fullName: 'Emma Smith',
      nisn: '0012345680',
      grade: '11',
      className: '11-C',
      gender: 'Female',
      birthDate: DateTime(2008, 3, 10),
      birthPlace: 'Surabaya',
      address: 'Jl. Gatot Subroto No. 456, Jakarta',
      parentId: 'parent_002',
      createdAt: DateTime(2024, 2, 20),
    ),
  ];

  static List<Student> getByParentId(String parentId) {
    return students.where((s) => s.parentId == parentId).toList();
  }
}
