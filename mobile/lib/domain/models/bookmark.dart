class Bookmark {
  final String id;
  final String? collectionId;
  final String title;
  final String url;
  final String? description;
  final String? notes;
  final String status;
  final int? rating;
  final bool isFavorite;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bookmark({
    required this.id,
    this.collectionId,
    required this.title,
    required this.url,
    this.description,
    this.notes,
    this.status = 'unread',
    this.rating,
    this.isFavorite = false,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      collectionId: json['collectionId'],
      title: json['title'],
      url: json['url'],
      description: json['description'],
      notes: json['notes'],
      status: json['status'] ?? 'unread',
      rating: json['rating'],
      isFavorite: json['isFavorite'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
