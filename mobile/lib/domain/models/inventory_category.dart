class InventoryCategory {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime createdAt;

  InventoryCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.createdAt,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
