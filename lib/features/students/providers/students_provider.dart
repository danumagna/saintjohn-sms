import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/dummy/dummy_students.dart';
import '../../../shared/providers/shared_providers.dart';
import '../data/repositories/students_repository.dart';
import '../domain/entities/student.dart';

/// Temporary draft state for student registration form.
class StudentRegistrationDraft {
  final int currentStep;
  final bool agreeInfoStepOne;
  final bool agreeInfoStepTwo;
  final String familyCardNumber;
  final String nik;
  final String fullName;
  final String birthDateText;
  final DateTime? selectedBirthDate;
  final String parentPhone;
  final String selectedAcademicYear;
  final String selectedGender;
  final String selectedSchoolLevel;
  final String selectedClass;
  final String selectedSchool;
  final String selectedPaymentMethod;
  final String? selectedPhotoPath;

  const StudentRegistrationDraft({
    required this.currentStep,
    required this.agreeInfoStepOne,
    required this.agreeInfoStepTwo,
    required this.familyCardNumber,
    required this.nik,
    required this.fullName,
    required this.birthDateText,
    required this.selectedBirthDate,
    required this.parentPhone,
    required this.selectedAcademicYear,
    required this.selectedGender,
    required this.selectedSchoolLevel,
    required this.selectedClass,
    required this.selectedSchool,
    required this.selectedPaymentMethod,
    required this.selectedPhotoPath,
  });
}

/// Stores the latest student registration draft in memory.
final studentRegistrationDraftProvider =
    StateProvider<StudentRegistrationDraft?>((ref) => null);

/// Students repository provider.
final studentsRepositoryProvider = Provider<StudentsRepository>((ref) {
  return StudentsRepository();
});

/// Students provider with API-first loading and local mutation support.
final studentsProvider = AsyncNotifierProvider<StudentsNotifier, List<Student>>(
  StudentsNotifier.new,
);

/// Handles loading and mutations for the student list.
class StudentsNotifier extends AsyncNotifier<List<Student>> {
  @override
  Future<List<Student>> build() async {
    return _fetchStudents();
  }

  Future<void> refreshStudents() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStudents);
  }

  Future<List<Student>> _fetchStudents() async {
    final repo = ref.read(studentsRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);

    final userToken = currentUser?.userToken?.trim() ?? '';
    final familyName = currentUser?.fullName.trim() ?? '';
    final nidParentUser = currentUser?.id.trim() ?? '';

    if (userToken.isEmpty || familyName.isEmpty || nidParentUser.isEmpty) {
      return List<Student>.from(DummyStudents.students);
    }

    return repo.getParentStudents(
      authToken: userToken,
      familyName: familyName,
      nidParentUser: nidParentUser,
    );
  }

  void addStudent(Student student) {
    DummyStudents.students.insert(0, student);

    final currentList = state.valueOrNull ?? <Student>[];
    state = AsyncValue.data(<Student>[student, ...currentList]);
  }

  void replaceWithDummyData() {
    state = AsyncValue.data(List<Student>.from(DummyStudents.students));
  }
}
