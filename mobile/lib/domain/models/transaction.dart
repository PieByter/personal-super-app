class Transaction {
  final String id;
  final String? categoryId;
  final String amount;
  final String type;
  final String? description;
  final String transactionDate;
  final String? paymentMethod;
  final List<String>? tags;
  final String? createdAt;
  final Category? category;

  Transaction({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.transactionDate,
    this.paymentMethod,
    this.tags,
    this.createdAt,
    this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'],
      type: json['type'],
      description: json['description'],
      transactionDate: json['transactionDate'],
      paymentMethod: json['paymentMethod'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: json['createdAt'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }
}

class Category {
  final String? id;
  final String? name;
  final String? color;
  final String? icon;

  Category({this.id, this.name, this.color, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      icon: json['icon'],
    );
  }
}
