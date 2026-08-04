class JournalTag {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  JournalTag({
    required this.id,
    required this.name,
    this.color = '#6366F1',
    required this.createdAt,
  });

  factory JournalTag.fromJson(Map<String, dynamic> json) {
    return JournalTag(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#6366F1',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
