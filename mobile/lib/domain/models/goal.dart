class SavingGoal {
  final String id;
  final String name;
  final String targetAmount;
  final String currentAmount;
  final String? deadline;
  final String color;
  final String? icon;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = '0',
    this.deadline,
    this.color = '#10B981',
    this.icon,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      id: json['id'],
      name: json['name'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'] ?? '0',
      deadline: json['deadline'],
      color: json['color'] ?? '#10B981',
      icon: json['icon'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
