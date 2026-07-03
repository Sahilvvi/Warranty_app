class User {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      email: json['email'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class LoginResponse {
  final String token;
  final String username;
  final String fullName;
  final String role;
  final DateTime expiresAt;

  LoginResponse({
    required this.token,
    required this.username,
    required this.fullName,
    required this.role,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
