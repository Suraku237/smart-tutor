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

  // Add this getter - it finds the index of the correct answer
  int get correctIndex {
    for (int i = 0; i < options.length; i++) {
      if (options[i] == correctAnswer) {
        return i;
      }
    }
    return 0; // Default to first option if not found (shouldn't happen)
  }
}