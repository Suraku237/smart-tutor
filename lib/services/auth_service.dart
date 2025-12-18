// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> saveLoginData(
      String token, String userId, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
  }

  static Future<Map<String, String>> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('auth_token') ?? '',
      'userId': prefs.getString('user_id') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
    };
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }
}