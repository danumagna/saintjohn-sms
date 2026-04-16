class StudentProgressGraphScoreItem {
  final String term;
  final String subjectName;
  final double finalGrade;
  final int termId;

  const StudentProgressGraphScoreItem({
    required this.term,
    required this.subjectName,
    required this.finalGrade,
    required this.termId,
  });

  factory StudentProgressGraphScoreItem.fromJson(Map<String, dynamic> json) {
    return StudentProgressGraphScoreItem(
      term: json['term']?.toString().trim() ?? '-',
      subjectName: json['subjectName']?.toString().trim() ?? '-',
      finalGrade: double.tryParse(json['finalGrade']?.toString() ?? '') ?? 0,
      termId: int.tryParse(json['termId']?.toString() ?? '') ?? 0,
    );
  }
}
