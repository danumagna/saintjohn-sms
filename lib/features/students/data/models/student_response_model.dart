import '../../domain/entities/student.dart';

/// Response model mapper for student list API.
class StudentResponseModel {
  StudentResponseModel._();

  static Student fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    final id = _pickString(json, const [
      'idStudent',
      'idCandidate',
      'idRegistrasi',
      'id',
      'student_id',
      'id_student',
    ]);
    final fullName = _pickString(json, const [
      'fullName',
      'full_name',
      'fullname',
      'name',
      'student_name',
    ]);
    final academicYear = _pickString(json, const [
      'schoolYear',
      'academic_year',
      'school_year',
      'tahun_ajaran',
    ]);
    final familyCardNumber = _pickString(json, const [
      'family_card_number',
      'kk_number',
      'no_kk',
    ]);
    final nik = _pickString(json, const ['nik', 'id_number']);
    final nisn = _pickString(json, const ['nisn', 'student_nisn']);
    final schoolLevel = _pickString(json, const [
      'schoolLevel',
      'school_level',
      'education_level',
      'jenjang',
    ]);
    final grade = _pickString(json, const [
      'schoolGrade',
      'grade',
      'kelas_tingkat',
    ]);
    final className = _pickString(json, const [
      'schoolGrade',
      'vclassName',
      'class_name',
      'classroom',
      'kelas',
    ]);
    final schoolName = _pickString(json, const [
      'schoolUnit',
      'schoolName',
      'school_name',
      'nama_sekolah',
    ]);
    final gender = _pickString(json, const ['gender', 'jenis_kelamin']);
    final birthPlace = _pickString(json, const ['birth_place', 'tempat_lahir']);
    final address = _pickString(json, const [
      'schoolAddress',
      'school_address',
      'address',
      'alamat',
    ]);
    final parentPhoneNumber = _pickString(json, const [
      'parent_phone_number',
      'phone_parent',
      'no_telp_ortu',
    ]);
    final paymentMethod = _pickString(json, const [
      'payment_method',
      'metode_pembayaran',
    ]);
    final parentId = _pickString(json, const ['parent_id', 'id_parent']);
    final statusCode = _pickString(json, const ['nstatusStudent']);
    final status = _pickString(json, const [
      'statusRegistrationFee',
      'testInformation',
      'status',
      'student_status',
    ]);
    final avatarUrl = _pickNullableString(json, const [
      'vstudentProfileFolderPublicFilePath',
      'avatar_url',
      'photo',
      'photo_url',
    ]);

    final normalizedClassName = className.isNotEmpty ? className : '-';
    final normalizedSchoolName = schoolName.isNotEmpty ? schoolName : '-';
    final normalizedStatus = status.isNotEmpty
        ? status
        : _mapStatusCode(statusCode);
    final derivedSchoolLevel = _deriveSchoolLevel(
      normalizedSchoolName,
      fallback: schoolLevel,
    );

    return Student(
      id: id.isNotEmpty ? id : 'std_unknown',
      fullName: fullName.isNotEmpty ? fullName : '-',
      academicYear: academicYear.isNotEmpty ? academicYear : '-',
      familyCardNumber: familyCardNumber.isNotEmpty ? familyCardNumber : '-',
      nik: nik.isNotEmpty ? nik : '-',
      nisn: nisn.isNotEmpty ? nisn : '-',
      schoolLevel: derivedSchoolLevel,
      grade: grade.isNotEmpty ? grade : '-',
      className: normalizedClassName,
      schoolName: normalizedSchoolName,
      gender: gender.isNotEmpty ? gender : '-',
      birthDate:
          _pickDate(json, const [
            'dob',
            'birth_date',
            'date_of_birth',
            'tanggal_lahir',
          ]) ??
          now,
      birthPlace: birthPlace.isNotEmpty ? birthPlace : '-',
      address: address.isNotEmpty ? address : '-',
      parentPhoneNumber: parentPhoneNumber.isNotEmpty ? parentPhoneNumber : '-',
      paymentMethod: paymentMethod.isNotEmpty ? paymentMethod : '-',
      parentId: parentId.isNotEmpty ? parentId : '-',
      status: normalizedStatus,
      avatarUrl: avatarUrl,
      createdAt: _pickDate(json, const ['created_at', 'createdAt']) ?? now,
    );
  }

  static String _mapStatusCode(String code) {
    switch (code) {
      case '1':
        return 'Active';
      case '2':
      case '3':
      case '4':
        return 'Inactive';
      default:
        return 'Inactive';
    }
  }

  static String _deriveSchoolLevel(String schoolName, {String? fallback}) {
    final fallbackValue = fallback?.trim() ?? '';
    if (fallbackValue.isNotEmpty) return fallbackValue;

    final upper = schoolName.toUpperCase();
    if (upper.contains('TK')) return 'TK';
    if (upper.contains('SD')) return 'SD';
    if (upper.contains('SMP')) return 'SMP';
    if (upper.contains('SMA')) return 'SMA';
    return '-';
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
    }
    return '';
  }

  static String? _pickNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = _pickString(json, keys);
    return value.isEmpty ? null : value;
  }

  static DateTime? _pickDate(Map<String, dynamic> json, List<String> keys) {
    final value = _pickString(json, keys);
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
