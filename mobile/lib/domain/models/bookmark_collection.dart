class BookmarkCollection {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String? icon;
  final String? parentId;
  final DateTime createdAt;

  BookmarkCollection({
    required this.id,
    required this.name,
    this.description,
    this.color = '#EC4899',
    this.icon,
    this.parentId,
    required this.createdAt,
  });

  factory BookmarkCollection.fromJson(Map<String, dynamic> json) {
    return BookmarkCollection(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'] ?? '#EC4899',
      icon: json['icon'],
      parentId: json['parentId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
