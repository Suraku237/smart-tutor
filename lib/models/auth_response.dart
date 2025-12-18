// lib/models/auth_response.dart
import 'package:smart_tutor/models/user_model.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}