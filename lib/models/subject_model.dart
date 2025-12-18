// lib/models/subject_model.dart
class Subject {
  final String id;
  final String name;
  final String icon;
  final String? description;
  final int lessonCount;
  final int quizCount;

  Subject({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    this.lessonCount = 0,
    this.quizCount = 0,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📘',
      description: json['description'],
      lessonCount: json['lesson_count'] ?? json['lessonCount'] ?? 0,
      quizCount: json['quiz_count'] ?? json['quizCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'lesson_count': lessonCount,
      'quiz_count': quizCount,
    };
  }
}