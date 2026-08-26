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
  final String? websiteId;
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
    this.websiteId,
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
      websiteId: json['websiteId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class JobWebsite {
  final String id;
  final String name;
  final String? url;
  final String status;
  final String? notes;
  final int totalApplications;
  final String? lastAppliedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobWebsite({
    required this.id,
    required this.name,
    this.url,
    this.status = 'active',
    this.notes,
    this.totalApplications = 0,
    this.lastAppliedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobWebsite.fromJson(Map<String, dynamic> json) {
    return JobWebsite(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      status: json['status'] ?? 'active',
      notes: json['notes'],
      totalApplications: json['totalApplications'] ?? 0,
      lastAppliedAt: json['lastAppliedAt'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
