// lib/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int lessonsCompleted;
  final int quizzesTaken;
  final int totalScore;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.lessonsCompleted = 0,
    this.quizzesTaken = 0,
    this.totalScore = 0,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      lessonsCompleted: json['lessons_completed'] ?? json['lessonsCompleted'] ?? 0,
      quizzesTaken: json['quizzes_taken'] ?? json['quizzesTaken'] ?? 0,
      totalScore: json['total_score'] ?? json['totalScore'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'lessons_completed': lessonsCompleted,
      'quizzes_taken': quizzesTaken,
      'total_score': totalScore,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}