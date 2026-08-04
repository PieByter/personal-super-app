class SubscriptionPayment {
  final String id;
  final String subscriptionId;
  final String amount;
  final String paymentDate;
  final String? notes;
  final DateTime createdAt;

  SubscriptionPayment({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      id: json['id'],
      subscriptionId: json['subscriptionId'],
      amount: json['amount'],
      paymentDate: json['paymentDate'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
