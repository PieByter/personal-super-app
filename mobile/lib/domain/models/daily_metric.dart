class DailyMetric {
  final String id;
  final String metricDate;
  final String? sleepHours;
  final String? studyHours;
  final String? codingHours;
  final int? exerciseMinutes;
  final int? readingMinutes;
  final int? screenTimeMinutes;
  final String? deepWorkHours;
  final int? mood;
  final int? energyLevel;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyMetric({
    required this.id,
    required this.metricDate,
    this.sleepHours,
    this.studyHours,
    this.codingHours,
    this.exerciseMinutes,
    this.readingMinutes,
    this.screenTimeMinutes,
    this.deepWorkHours,
    this.mood,
    this.energyLevel,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyMetric.fromJson(Map<String, dynamic> json) {
    return DailyMetric(
      id: json['id'],
      metricDate: json['metricDate'],
      sleepHours: json['sleepHours']?.toString(),
      studyHours: json['studyHours']?.toString(),
      codingHours: json['codingHours']?.toString(),
      exerciseMinutes: json['exerciseMinutes'],
      readingMinutes: json['readingMinutes'],
      screenTimeMinutes: json['screenTimeMinutes'],
      deepWorkHours: json['deepWorkHours']?.toString(),
      mood: json['mood'],
      energyLevel: json['energyLevel'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
