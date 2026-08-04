class Interview {
  final String id;
  final String jobId;
  final int round;
  final String interviewType;
  final DateTime? scheduledAt;
  final int? durationMinutes;
  final String? location;
  final String? meetingUrl;
  final String? interviewerName;
  final String? interviewerEmail;
  final String? notes;
  final String status;
  final DateTime createdAt;

  Interview({
    required this.id,
    required this.jobId,
    this.round = 1,
    required this.interviewType,
    this.scheduledAt,
    this.durationMinutes,
    this.location,
    this.meetingUrl,
    this.interviewerName,
    this.interviewerEmail,
    this.notes,
    this.status = 'scheduled',
    required this.createdAt,
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'],
      jobId: json['jobId'],
      round: json['round'] ?? 1,
      interviewType: json['interviewType'],
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      durationMinutes: json['durationMinutes'],
      location: json['location'],
      meetingUrl: json['meetingUrl'],
      interviewerName: json['interviewerName'],
      interviewerEmail: json['interviewerEmail'],
      notes: json['notes'],
      status: json['status'] ?? 'scheduled',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
