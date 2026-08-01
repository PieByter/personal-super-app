class JournalEntry {
  final String id;
  final String title;
  final String? problem;
  final String? rootCause;
  final String? solution;
  final String? conceptLearned;
  final String? codeSnippet;
  final String? language;
  final String? projectName;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    this.problem,
    this.rootCause,
    this.solution,
    this.conceptLearned,
    this.codeSnippet,
    this.language,
    this.projectName,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'],
      problem: json['problem'],
      rootCause: json['rootCause'],
      solution: json['solution'],
      conceptLearned: json['conceptLearned'],
      codeSnippet: json['codeSnippet'],
      language: json['language'],
      projectName: json['projectName'],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
