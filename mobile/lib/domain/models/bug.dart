class BugEntry {
  final String id;
  final String? bugCode;
  final String title;
  final String? projectName;
  final String? technology;
  final String? errorMessage;
  final String? errorType;
  final String? cause;
  final String? solution;
  final String status;
  final String severity;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? solvedAt;

  BugEntry({
    required this.id,
    this.bugCode,
    required this.title,
    this.projectName,
    this.technology,
    this.errorMessage,
    this.errorType,
    this.cause,
    this.solution,
    this.status = 'open',
    this.severity = 'medium',
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.solvedAt,
  });

  factory BugEntry.fromJson(Map<String, dynamic> json) {
    return BugEntry(
      id: json['id'],
      bugCode: json['bugCode'],
      title: json['title'],
      projectName: json['projectName'],
      technology: json['technology'],
      errorMessage: json['errorMessage'],
      errorType: json['errorType'],
      cause: json['cause'],
      solution: json['solution'],
      status: json['status'] ?? 'open',
      severity: json['severity'] ?? 'medium',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      solvedAt:
          json['solvedAt'] != null ? DateTime.parse(json['solvedAt']) : null,
    );
  }
}
