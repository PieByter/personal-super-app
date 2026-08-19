class RecurringRule {
  final String id;
  final String? categoryId;
  final String amount;
  final String type;
  final String frequency;
  final int interval;
  final String startDate;
  final String? endDate;
  final String? description;
  final String nextExecution;
  final bool isActive;
  final DateTime createdAt;

  RecurringRule({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.type,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    this.description,
    required this.nextExecution,
    this.isActive = true,
    required this.createdAt,
  });

  factory RecurringRule.fromJson(Map<String, dynamic> json) {
    return RecurringRule(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'],
      type: json['type'],
      frequency: json['frequency'],
      interval: json['interval'] ?? 1,
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
      nextExecution: json['nextExecution'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
