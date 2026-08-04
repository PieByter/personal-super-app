class Milestone {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String? dueDate;
  final DateTime? completedAt;
  final bool isCompleted;
  final DateTime createdAt;

  Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.dueDate,
    this.completedAt,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
