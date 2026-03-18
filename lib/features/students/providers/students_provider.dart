import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/dummy/dummy_students.dart';
import '../domain/entities/student.dart';

/// Students state provider for in-memory registration updates.
final studentsProvider = StateNotifierProvider<StudentsNotifier, List<Student>>(
  (ref) {
    return StudentsNotifier();
  },
);

/// Handles student list mutations for the current app session.
class StudentsNotifier extends StateNotifier<List<Student>> {
  StudentsNotifier() : super(List<Student>.from(DummyStudents.students));

  void addStudent(Student student) {
    DummyStudents.students.insert(0, student);
    state = List<Student>.from(DummyStudents.students);
  }
}
