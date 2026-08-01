class Project {
  final String id;
  final String name;
  final String? description;
  final String? goal;
  final String status;
  final String priority;
  final String? progress;
  final String? startDate;
  final String? targetDate;
  final List<String>? techStack;
  final String? gitRepository;
  final String? documentationUrl;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.goal,
    this.status = 'active',
    this.priority = 'medium',
    this.progress,
    this.startDate,
    this.targetDate,
    this.techStack,
    this.gitRepository,
    this.documentationUrl,
    this.color = '#8B5CF6',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      goal: json['goal'],
      status: json['status'] ?? 'active',
      priority: json['priority'] ?? 'medium',
      progress: json['progress'],
      startDate: json['startDate'],
      targetDate: json['targetDate'],
      techStack: json['techStack'] != null
          ? List<String>.from(json['techStack'])
          : null,
      gitRepository: json['gitRepository'],
      documentationUrl: json['documentationUrl'],
      color: json['color'] ?? '#8B5CF6',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
