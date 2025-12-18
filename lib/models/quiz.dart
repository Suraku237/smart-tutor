// lib/models/quiz.dart
class Quiz {
  final String id;
  final String lessonId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? json['_id'] ?? '',
      lessonId: json['lesson_id'] ?? json['lessonId'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? json['correctAnswer'] ?? '',
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }

  int get correctIndex {
    for (int i = 0; i < options.length; i++) {
      if (options[i] == correctAnswer) {
        return i;
      }
    }
    return 0;
  }
}