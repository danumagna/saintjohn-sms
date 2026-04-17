import '../../domain/entities/student.dart';

/// Response model mapper for student list API.
class StudentResponseModel {
  StudentResponseModel._();

  static Student fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final sourceType = _detectSourceType(json);

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

    final registrationId = _pickString(json, const ['idRegistrasi']);
    final statusCode = _pickString(json, const ['nstatusStudent']);
    final moveOutReasonCode = _pickString(json, const ['nreasonMoveOut']);
    final classGraduate = _pickString(json, const ['vclassGraduate']);
    final homeRoomTeacher = _pickString(json, const [
      'vstudentHomeRoomTeacher',
    ]);
    final reregisterOpenStatus = _pickString(json, const [
      'reregisterOpenStatus',
    ]);
    final reregisterPaymentExist = _pickString(json, const [
      'vparentStudentReregisterPaymentExist',
    ]);
    final reregisterPaymentPaid = _pickString(json, const [
      'vparentStudentReregisterPaymentPaid',
    ]);
    final reregisterProfileComplete = _pickString(json, const [
      'vparentStudentReregisterProfileComplete',
    ]);

    final candidateStatus = _pickString(json, const ['candidateStatus']);
    final statusRegistrationFee = _pickString(json, const [
      'statusRegistrationFee',
    ]);
    final statusBuildingFee = _pickString(json, const ['statusBuildingFee']);
    final testInformation = _pickString(json, const ['testInformation']);
    final profileDataInformation = _pickString(json, const [
      'profileDataInformation',
    ]);

    final statusInfo = _buildStatusInfo(
      sourceType: sourceType,
      statusCode: statusCode,
      moveOutReasonCode: moveOutReasonCode,
      classGraduate: classGraduate,
      homeRoomTeacher: homeRoomTeacher,
      reregisterOpenStatus: reregisterOpenStatus,
      reregisterPaymentExist: reregisterPaymentExist,
      reregisterPaymentPaid: reregisterPaymentPaid,
      reregisterProfileComplete: reregisterProfileComplete,
      candidateStatus: candidateStatus,
      statusRegistrationFee: statusRegistrationFee,
      statusBuildingFee: statusBuildingFee,
      testInformation: testInformation,
      profileDataInformation: profileDataInformation,
    );

    final avatarUrl = _pickNullableString(json, const [
      'vstudentProfileFolderPublicFilePath',
      'vcandidateProfileFolderPublicFilePath',
      'avatar_url',
      'photo',
      'photo_url',
    ]);

    final normalizedClassName = className.isNotEmpty ? className : '-';
    final normalizedSchoolName = schoolName.isNotEmpty ? schoolName : '-';
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
      status: statusInfo.title,
      statusTitle: statusInfo.title,
      statusDescription: statusInfo.description,
      sourceType: sourceType,
      registrationId: registrationId.isNotEmpty ? registrationId : '-',
      homeRoomTeacher: homeRoomTeacher.isNotEmpty ? homeRoomTeacher : '-',
      reregisterOpenStatus: reregisterOpenStatus.isNotEmpty
          ? reregisterOpenStatus
          : '-',
      registrationFeeStatus: statusRegistrationFee.isNotEmpty
          ? statusRegistrationFee
          : '-',
      buildingFeeStatus: statusBuildingFee.isNotEmpty ? statusBuildingFee : '-',
      testInformation: testInformation.isNotEmpty ? testInformation : '-',
      profileDataInformation: profileDataInformation.isNotEmpty
          ? profileDataInformation
          : '-',
      avatarUrl: avatarUrl,
      createdAt: _pickDate(json, const ['created_at', 'createdAt']) ?? now,
    );
  }

  static String _detectSourceType(Map<String, dynamic> json) {
    if ((json['idCandidate']?.toString().trim() ?? '').isNotEmpty) {
      return 'candidate';
    }
    if ((json['idStudent']?.toString().trim() ?? '').isNotEmpty) {
      return 'student';
    }
    return 'student';
  }

  static _StudentStatusInfo _buildStatusInfo({
    required String sourceType,
    required String statusCode,
    required String moveOutReasonCode,
    required String classGraduate,
    required String homeRoomTeacher,
    required String reregisterOpenStatus,
    required String reregisterPaymentExist,
    required String reregisterPaymentPaid,
    required String reregisterProfileComplete,
    required String candidateStatus,
    required String statusRegistrationFee,
    required String statusBuildingFee,
    required String testInformation,
    required String profileDataInformation,
  }) {
    final normalizedTest = testInformation.toLowerCase();
    final normalizedProfile = profileDataInformation.toLowerCase();
    final normalizedRegFee = statusRegistrationFee.toLowerCase();
    final normalizedBuildingFee = statusBuildingFee.toLowerCase();

    if (sourceType == 'candidate') {
      if (candidateStatus == '9') {
        return const _StudentStatusInfo(
          title: 'Proses Administrasi Dihentikan',
          description:
              'Kami mohon maaf, peserta didik dinyatakan berhenti dalam '
              'proses administrasi.',
        );
      }

      if (candidateStatus == '7' || normalizedTest.contains('negosiasi')) {
        return const _StudentStatusInfo(
          title: 'Proses Administrasi Dihentikan',
          description:
              'Kami mohon maaf, peserta didik dinyatakan berhenti dalam '
              'proses administrasi.',
        );
      }

      if (normalizedTest.contains('lulus')) {
        final profileComplete = normalizedProfile.contains('lengkap');
        final buildingPaid =
            normalizedBuildingFee.contains('lunas') ||
            normalizedBuildingFee.contains('gratis');

        if (profileComplete && buildingPaid) {
          return const _StudentStatusInfo(
            title: 'Daftar Ulang Berhasil',
            description:
                'Siswa telah berhasil melakukan Daftar Ulang. Pendaftaran '
                'akan segera diproses Admin.',
          );
        }

        return const _StudentStatusInfo(
          title: 'Lengkapi Profil dan Pembayaran',
          description:
              'Silakan lengkapi data profil peserta didik di menu data '
              "profil dan selesaikan pembayaran uang pangkal sesegera "
              'mungkin sesuai nominal yang tertera di status pembayaran '
              'uang pangkal.',
        );
      }

      if (normalizedTest.contains('diumumkan')) {
        return const _StudentStatusInfo(
          title: 'Informasi Wali Kelas Menunggu',
          description: 'Wali Kelas Akan Segera Diumumkan.',
        );
      }

      if (normalizedRegFee.contains('sudah diproses') ||
          normalizedRegFee.contains('gratis')) {
        return const _StudentStatusInfo(
          title: 'Menunggu Tes Evaluasi',
          description:
              'Silakan calon peserta didik melakukan tes evaluasi pada '
              'waktu dan tempat yang tertera di informasi tes.',
        );
      }

      return const _StudentStatusInfo(
        title: 'Dalam Proses Administrasi',
        description:
            'Data Anda sedang diproses. Selanjutnya Admin St John akan '
            'menghubungi Anda.',
      );
    }

    if (moveOutReasonCode == '1' ||
        classGraduate.toLowerCase() == 'kelaslulus') {
      return const _StudentStatusInfo(
        title: 'Lulus',
        description: 'Selamat kepada siswa yang lulus.',
      );
    }

    if (moveOutReasonCode == '2') {
      return const _StudentStatusInfo(
        title: 'Mutasi Siswa',
        description: 'Mutasi Siswa.',
      );
    }

    if (moveOutReasonCode == '5' || moveOutReasonCode == '4') {
      return const _StudentStatusInfo(
        title: 'Tidak Lulus atau Tinggal Kelas',
        description:
            'Mohon maaf siswa dinyatakan tinggal kelas atau tidak lulus.',
      );
    }

    if (moveOutReasonCode == '6') {
      return const _StudentStatusInfo(
        title: 'Mengundurkan Diri',
        description:
            'Siswa dinyatakan Mengundurkan Diri dan tidak melanjutkan '
            'pendidikan.',
      );
    }

    if (moveOutReasonCode == '7') {
      return const _StudentStatusInfo(
        title: 'Dikeluarkan',
        description:
            'Siswa dinyatakan Dikeluarkan dari sekolah dan tidak '
            'melanjutkan pendidikan.',
      );
    }

    if (statusCode == '1') {
      if (reregisterOpenStatus.toUpperCase() == 'TUTUP') {
        return const _StudentStatusInfo(
          title: 'Daftar Ulang Ditutup',
          description: 'Daftar ulang untuk Tahun Ajaran Baru sudah ditutup.',
        );
      }

      final isPaymentReady =
          reregisterPaymentExist == '1' &&
          reregisterPaymentPaid == '1' &&
          reregisterProfileComplete == '1';
      if (isPaymentReady) {
        return const _StudentStatusInfo(
          title: 'Daftar Ulang Berhasil',
          description:
              'Siswa telah berhasil melakukan Daftar Ulang. Pendaftaran '
              'akan segera diproses Admin.',
        );
      }

      if (homeRoomTeacher.trim().isEmpty) {
        return const _StudentStatusInfo(
          title: 'Menunggu Pengumuman Wali Kelas',
          description: 'Wali Kelas Akan Segera Diumumkan.',
        );
      }

      return const _StudentStatusInfo(
        title: 'Siswa Aktif',
        description: 'Data siswa aktif dan tercatat pada sistem sekolah.',
      );
    }

    return const _StudentStatusInfo(
      title: 'Dalam Proses Administrasi',
      description:
          'Data Anda sedang diproses. Selanjutnya Admin St John akan '
          'menghubungi Anda.',
    );
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

class _StudentStatusInfo {
  final String title;
  final String description;

  const _StudentStatusInfo({required this.title, required this.description});
}
