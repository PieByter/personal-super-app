class User {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String timezone;
  final String currency;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.timezone = 'Asia/Jakarta',
    this.currency = 'IDR',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      timezone: json['timezone'] ?? 'Asia/Jakarta',
      currency: json['currency'] ?? 'IDR',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    'timezone': timezone,
    'currency': currency,
  };
}
