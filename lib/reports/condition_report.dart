class ConditionReport {
  const ConditionReport({
    this.id = '',
    required this.artist,
    required this.title,
    required this.medium,
    required this.condition,
    required this.issues,
    required this.notes,
    required this.createdAt,
    required this.createdByUid,
    required this.createdByName,
    required this.createdByEmail,
    this.hasPhoto = false,
  });

  final String id;
  final String artist;
  final String title;
  final String medium;

  final String condition;

  final List<String> issues;
  final String notes;
  final DateTime createdAt;

  final String createdByUid;
  final String createdByName;
  final String createdByEmail;

  final bool hasPhoto;

  String get displayTitle => title.trim().isEmpty ? 'Untitled' : title.trim();

  String get dateLabel =>
      '${createdAt.month}/${createdAt.day}/${createdAt.year}';

  Map<String, dynamic> toMap() {
    return {
      'artist': artist,
      'title': title,
      'medium': medium,
      'condition': condition,
      'issues': issues,
      'notes': notes,
      'createdAt': createdAt,
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      'createdByEmail': createdByEmail,
      'hasPhoto': hasPhoto,
    };
  }

  factory ConditionReport.fromMap(String id, Map<String, dynamic> map) {
    return ConditionReport(
      id: id,
      artist: map['artist'] as String? ?? '',
      title: map['title'] as String? ?? '',
      medium: map['medium'] as String? ?? '',
      condition: map['condition'] as String? ?? '',
      issues: List<String>.from(map['issues'] as List? ?? const []),
      notes: map['notes'] as String? ?? '',
      createdAt: map['createdAt'] as DateTime? ?? DateTime(2000),
      createdByUid: map['createdByUid'] as String? ?? '',
      createdByName: map['createdByName'] as String? ?? 'Unknown',
      createdByEmail: map['createdByEmail'] as String? ?? '',
      hasPhoto: map['hasPhoto'] as bool? ?? false,
    );
  }
}
