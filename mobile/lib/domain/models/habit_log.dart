class HabitLog {
  final String id;
  final String habitId;
  final String logDate;
  final String value;
  final String? notes;
  final String? mood;
  final DateTime createdAt;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.logDate,
    this.value = '1',
    this.notes,
    this.mood,
    required this.createdAt,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'],
      habitId: json['habitId'],
      logDate: json['logDate'],
      value: json['value'] ?? '1',
      notes: json['notes'],
      mood: json['mood'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
