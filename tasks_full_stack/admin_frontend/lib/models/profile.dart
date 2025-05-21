class Profile {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? registrationNumber;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.registrationNumber,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      registrationNumber: json['registration_number'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'registration_number': registrationNumber,
    'email_verified_at': emailVerifiedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
