class Investment {
  final String id;
  final String name;
  final String type;
  final String? symbol;
  final String quantity;
  final String purchasePrice;
  final String? currentPrice;
  final String purchaseDate;
  final String? broker;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Investment({
    required this.id,
    required this.name,
    required this.type,
    this.symbol,
    required this.quantity,
    required this.purchasePrice,
    this.currentPrice,
    required this.purchaseDate,
    this.broker,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      symbol: json['symbol'],
      quantity: json['quantity'],
      purchasePrice: json['purchasePrice'],
      currentPrice: json['currentPrice'],
      purchaseDate: json['purchaseDate'],
      broker: json['broker'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
