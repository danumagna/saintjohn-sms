/// Student entity for the students feature.
class Student {
  final String id;
  final String fullName;
  final String academicYear;
  final String familyCardNumber;
  final String nik;
  final String nisn; // Nomor Induk Siswa Nasional
  final String schoolLevel;
  final String grade;
  final String className;
  final String schoolName;
  final String gender;
  final DateTime birthDate;
  final String birthPlace;
  final String address;
  final String parentPhoneNumber;
  final String paymentMethod;
  final String parentId;
  final String status;
  final String statusTitle;
  final String statusDescription;
  final String sourceType;
  final String registrationId;
  final String homeRoomTeacher;
  final String reregisterOpenStatus;
  final String registrationFeeStatus;
  final String buildingFeeStatus;
  final String testInformation;
  final String profileDataInformation;
  final String? avatarUrl;
  final DateTime createdAt;

  const Student({
    required this.id,
    required this.fullName,
    required this.academicYear,
    required this.familyCardNumber,
    required this.nik,
    required this.nisn,
    required this.schoolLevel,
    required this.grade,
    required this.className,
    required this.schoolName,
    required this.gender,
    required this.birthDate,
    required this.birthPlace,
    required this.address,
    required this.parentPhoneNumber,
    required this.paymentMethod,
    required this.parentId,
    this.status = 'Active',
    this.statusTitle = 'Status Aktif',
    this.statusDescription = 'Data siswa aktif.',
    this.sourceType = 'student',
    this.registrationId = '-',
    this.homeRoomTeacher = '-',
    this.reregisterOpenStatus = '-',
    this.registrationFeeStatus = '-',
    this.buildingFeeStatus = '-',
    this.testInformation = '-',
    this.profileDataInformation = '-',
    this.avatarUrl,
    required this.createdAt,
  });

  /// Alias for fullName for convenience.
  String get name => fullName;

  Student copyWith({
    String? id,
    String? fullName,
    String? academicYear,
    String? familyCardNumber,
    String? nik,
    String? nisn,
    String? schoolLevel,
    String? grade,
    String? className,
    String? schoolName,
    String? gender,
    DateTime? birthDate,
    String? birthPlace,
    String? address,
    String? parentPhoneNumber,
    String? paymentMethod,
    String? parentId,
    String? status,
    String? statusTitle,
    String? statusDescription,
    String? sourceType,
    String? registrationId,
    String? homeRoomTeacher,
    String? reregisterOpenStatus,
    String? registrationFeeStatus,
    String? buildingFeeStatus,
    String? testInformation,
    String? profileDataInformation,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      academicYear: academicYear ?? this.academicYear,
      familyCardNumber: familyCardNumber ?? this.familyCardNumber,
      nik: nik ?? this.nik,
      nisn: nisn ?? this.nisn,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      grade: grade ?? this.grade,
      className: className ?? this.className,
      schoolName: schoolName ?? this.schoolName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      address: address ?? this.address,
      parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      statusTitle: statusTitle ?? this.statusTitle,
      statusDescription: statusDescription ?? this.statusDescription,
      sourceType: sourceType ?? this.sourceType,
      registrationId: registrationId ?? this.registrationId,
      homeRoomTeacher: homeRoomTeacher ?? this.homeRoomTeacher,
      reregisterOpenStatus: reregisterOpenStatus ?? this.reregisterOpenStatus,
      registrationFeeStatus:
          registrationFeeStatus ?? this.registrationFeeStatus,
      buildingFeeStatus: buildingFeeStatus ?? this.buildingFeeStatus,
      testInformation: testInformation ?? this.testInformation,
      profileDataInformation:
          profileDataInformation ?? this.profileDataInformation,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
