// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import '../models/subject_model.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';
import '../models/sentiment_response.dart';
import '../models/api_response.dart';

class ApiService {
  static const String baseUrl = 'http://YOUR_VPS_IP:3000/api'; // Change this
  static const int timeoutSeconds = 30;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ========== AUTH ENDPOINTS ==========
  static Future<ApiResponse<AuthResponse>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(responseData);
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authResponse.token);
        await prefs.setString('user_id', authResponse.user.id);
        await prefs.setString('user_email', authResponse.user.email);
        await prefs.setString('user_name', authResponse.user.name);

        return ApiResponse<AuthResponse>(
          success: true,
          message: 'Login successful',
          data: authResponse,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: responseData['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  static Future<ApiResponse<AuthResponse>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(responseData);
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authResponse.token);
        await prefs.setString('user_id', authResponse.user.id);
        await prefs.setString('user_email', authResponse.user.email);
        await prefs.setString('user_name', authResponse.user.name);

        return ApiResponse<AuthResponse>(
          success: true,
          message: 'Registration successful',
          data: authResponse,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: responseData['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }

  // ========== SUBJECTS ENDPOINTS ==========
  static Future<ApiResponse<List<Subject>>> getSubjects() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subjects'),
        headers: headers,
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<Subject> subjects = (responseData['data'] as List)
            .map((item) => Subject.fromJson(item))
            .toList();

        return ApiResponse<List<Subject>>(
          success: true,
          message: 'Subjects loaded successfully',
          data: subjects,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<Subject>>(
          success: false,
          message: responseData['message'] ?? 'Failed to load subjects',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<Subject>>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // ========== LESSONS ENDPOINTS ==========
  static Future<ApiResponse<List<Lesson>>> getLessons(String subjectId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subjects/$subjectId/lessons'),
        headers: headers,
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<Lesson> lessons = (responseData['data'] as List)
            .map((item) => Lesson.fromJson(item))
            .toList();

        return ApiResponse<List<Lesson>>(
          success: true,
          message: 'Lessons loaded successfully',
          data: lessons,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<Lesson>>(
          success: false,
          message: responseData['message'] ?? 'Failed to load lessons',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<Lesson>>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  static Future<ApiResponse<void>> markLessonComplete(
      String lessonId, int? quizScore) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lessons/$lessonId/complete'),
        headers: headers,
        body: jsonEncode({
          'quiz_score': quizScore,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Lesson marked as complete',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Failed to mark lesson complete',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // ========== QUIZ ENDPOINTS ==========
  static Future<ApiResponse<List<Quiz>>> getQuiz(String lessonId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId/quiz'),
        headers: headers,
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<Quiz> quizzes = (responseData['data'] as List)
            .map((item) => Quiz.fromJson(item))
            .toList();

        return ApiResponse<List<Quiz>>(
          success: true,
          message: 'Quiz loaded successfully',
          data: quizzes,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<Quiz>>(
          success: false,
          message: responseData['message'] ?? 'Failed to load quiz',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<Quiz>>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> submitQuiz(
      String lessonId, int score, int total) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lessons/$lessonId/quiz/submit'),
        headers: headers,
        body: jsonEncode({
          'score': score,
          'total': total,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Quiz submitted successfully',
          data: responseData['data'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Failed to submit quiz',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // ========== SENTIMENT ENDPOINT ==========
  static Future<ApiResponse<SentimentResponse>> analyzeSentiment(
      String text) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/sentiment/analyze'),
        headers: headers,
        body: jsonEncode({
          'text': text,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final sentimentResponse = SentimentResponse.fromJson(responseData['data']);

        return ApiResponse<SentimentResponse>(
          success: true,
          message: 'Sentiment analyzed successfully',
          data: sentimentResponse,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<SentimentResponse>(
          success: false,
          message: responseData['message'] ?? 'Failed to analyze sentiment',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<SentimentResponse>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // ========== USER PROFILE ENDPOINTS ==========
  static Future<ApiResponse<User>> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(responseData['data']);

        return ApiResponse<User>(
          success: true,
          message: 'Profile loaded successfully',
          data: user,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Failed to load profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  static Future<ApiResponse<User>> updateProfile(
      String name, String? avatar) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          if (avatar != null) 'avatar': avatar,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(responseData['data']);

        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', user.name);

        return ApiResponse<User>(
          success: true,
          message: 'Profile updated successfully',
          data: user,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // ========== UTILITY METHODS ==========
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');

    if (id == null || name == null || email == null) {
      return null;
    }

    return User(
      id: id,
      name: name,
      email: email,
    );
  }
}