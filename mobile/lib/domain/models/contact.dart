class JobContact {
  final String id;
  final String jobId;
  final String name;
  final String? role;
  final String? email;
  final String? phone;
  final String? linkedinUrl;
  final String? notes;
  final DateTime createdAt;

  JobContact({
    required this.id,
    required this.jobId,
    required this.name,
    this.role,
    this.email,
    this.phone,
    this.linkedinUrl,
    this.notes,
    required this.createdAt,
  });

  factory JobContact.fromJson(Map<String, dynamic> json) {
    return JobContact(
      id: json['id'],
      jobId: json['jobId'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      linkedinUrl: json['linkedinUrl'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
