class User {
  final int? id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final String? registrationNumber;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    this.registrationNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: json['role'] as String,
      registrationNumber: json['registration_number'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'email_verified_at': emailVerifiedAt,
    'role': role,
    'registration_number': registrationNumber,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
