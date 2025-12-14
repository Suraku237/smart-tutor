// lib/models/quiz.dart
class Quiz {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Quiz({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  // Add this getter
  int get correctIndex => options.indexOf(correctAnswer);
}