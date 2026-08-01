class InventoryItem {
  final String id;
  final String? categoryId;
  final String name;
  final String? description;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? currentValue;
  final String condition;
  final String? location;
  final String? warrantyExpiry;
  final List<String>? tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    this.brand,
    this.model,
    this.serialNumber,
    this.purchaseDate,
    this.purchasePrice,
    this.currentValue,
    this.condition = 'good',
    this.location,
    this.warrantyExpiry,
    this.tags,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['name'],
      description: json['description'],
      brand: json['brand'],
      model: json['model'],
      serialNumber: json['serialNumber'],
      purchaseDate: json['purchaseDate'],
      purchasePrice: json['purchasePrice'],
      currentValue: json['currentValue'],
      condition: json['condition'] ?? 'good',
      location: json['location'],
      warrantyExpiry: json['warrantyExpiry'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
