class Habit {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String color;
  final String? targetValue;
  final String? unit;
  final String frequency;
  final List<int>? targetDays;
  final String? reminderTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color = '#F59E0B',
    this.targetValue,
    this.unit,
    required this.frequency,
    this.targetDays,
    this.reminderTime,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'] ?? '#F59E0B',
      targetValue: json['targetValue'],
      unit: json['unit'],
      frequency: json['frequency'],
      targetDays: json['targetDays'] != null
          ? List<int>.from(json['targetDays'])
          : null,
      reminderTime: json['reminderTime'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
