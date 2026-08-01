class Subscription {
  final String id;
  final String name;
  final String? description;
  final String? provider;
  final String? category;
  final String amount;
  final String currency;
  final String billingCycle;
  final String? nextRenewalDate;
  final String? startDate;
  final String? paymentMethod;
  final bool isActive;
  final int? reminderDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.name,
    this.description,
    this.provider,
    this.category,
    required this.amount,
    this.currency = 'IDR',
    required this.billingCycle,
    this.nextRenewalDate,
    this.startDate,
    this.paymentMethod,
    this.isActive = true,
    this.reminderDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      provider: json['provider'],
      category: json['category'],
      amount: json['amount'],
      currency: json['currency'] ?? 'IDR',
      billingCycle: json['billingCycle'],
      nextRenewalDate: json['nextRenewalDate'],
      startDate: json['startDate'],
      paymentMethod: json['paymentMethod'],
      isActive: json['isActive'] ?? true,
      reminderDays: json['reminderDays'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
