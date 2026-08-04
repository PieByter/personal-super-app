class Budget {
  final String id;
  final String? categoryId;
  final String amount;
  final String period;
  final String startDate;
  final String? endDate;
  final String? alertThreshold;
  final bool isActive;
  final DateTime createdAt;

  Budget({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    this.alertThreshold,
    this.isActive = true,
    required this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'],
      period: json['period'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      alertThreshold: json['alertThreshold'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
