// lib/models/lesson.dart
class Lesson {
  final String id;
  final String subjectId;
  final String title;
  final String description;
  final String content;
  final int order;
  final bool isCompleted;
  final int? quizScore;

  Lesson({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.content,
    this.order = 0,
    this.isCompleted = false,
    this.quizScore,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? json['_id'] ?? '',
      subjectId: json['subject_id'] ?? json['subjectId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      order: json['order'] ?? json['order_index'] ?? 0,
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      quizScore: json['quiz_score'] ?? json['quizScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'content': content,
      'order': order,
      'is_completed': isCompleted,
      'quiz_score': quizScore,
    };
  }
}