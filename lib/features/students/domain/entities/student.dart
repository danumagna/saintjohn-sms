/// Student entity for the students feature.
class Student {
  final String id;
  final String fullName;
  final String nisn; // Nomor Induk Siswa Nasional
  final String grade;
  final String className;
  final String gender;
  final DateTime birthDate;
  final String birthPlace;
  final String address;
  final String parentId;
  final String status;
  final String? avatarUrl;
  final DateTime createdAt;

  const Student({
    required this.id,
    required this.fullName,
    required this.nisn,
    required this.grade,
    required this.className,
    required this.gender,
    required this.birthDate,
    required this.birthPlace,
    required this.address,
    required this.parentId,
    this.status = 'Active',
    this.avatarUrl,
    required this.createdAt,
  });

  /// Alias for fullName for convenience.
  String get name => fullName;

  Student copyWith({
    String? id,
    String? fullName,
    String? nisn,
    String? grade,
    String? className,
    String? gender,
    DateTime? birthDate,
    String? birthPlace,
    String? address,
    String? parentId,
    String? status,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nisn: nisn ?? this.nisn,
      grade: grade ?? this.grade,
      className: className ?? this.className,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      address: address ?? this.address,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
