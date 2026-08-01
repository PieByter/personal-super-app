class JobApplication {
  final String id;
  final String companyName;
  final String position;
  final String? salaryRange;
  final String? location;
  final String? jobType;
  final String status;
  final String applicationDate;
  final String? jobDescription;
  final String? notes;
  final String? url;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobApplication({
    required this.id,
    required this.companyName,
    required this.position,
    this.salaryRange,
    this.location,
    this.jobType,
    this.status = 'applied',
    required this.applicationDate,
    this.jobDescription,
    this.notes,
    this.url,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      companyName: json['companyName'],
      position: json['position'],
      salaryRange: json['salaryRange'],
      location: json['location'],
      jobType: json['jobType'],
      status: json['status'] ?? 'applied',
      applicationDate: json['applicationDate'],
      jobDescription: json['jobDescription'],
      notes: json['notes'],
      url: json['url'],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
