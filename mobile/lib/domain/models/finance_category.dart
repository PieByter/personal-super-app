class FinanceCategory {
  final String id;
  final String name;
  final String type;
  final String color;
  final String? icon;
  final String? parentId;
  final DateTime createdAt;

  FinanceCategory({
    required this.id,
    required this.name,
    required this.type,
    this.color = '#3B82F6',
    this.icon,
    this.parentId,
    required this.createdAt,
  });

  factory FinanceCategory.fromJson(Map<String, dynamic> json) {
    return FinanceCategory(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      color: json['color'] ?? '#3B82F6',
      icon: json['icon'],
      parentId: json['parentId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
