class ProjectTask {
  final String id;
  final String projectId;
  final String? milestoneId;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? dueDate;
  final DateTime? completedAt;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectTask({
    required this.id,
    required this.projectId,
    this.milestoneId,
    required this.title,
    this.description,
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
    this.completedAt,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: json['id'],
      projectId: json['projectId'],
      milestoneId: json['milestoneId'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      dueDate: json['dueDate'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
