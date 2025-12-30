import 'package:flutter/material.dart';
// Replace 'smartproject' with the name found in your pubspec.yaml
import 'package:smartproject/screens/lesson_page.dart';

class LessonCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subjectId; // This identifies the subject (e.g., 'math')
  final VoidCallback onTapQuiz;

  const LessonCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subjectId,
    required this.onTapQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // EMOJI SECTION
          Text(
            emoji,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 8),

          // TITLE SECTION
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // BUTTONS SECTION
          Row(
            children: [
              // LESSON BUTTON
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the dynamic LessonPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonPage(
                            subjectId: subjectId,
                            title: title,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Lesson",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              // QUIZ BUTTON
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: OutlinedButton(
                    onPressed: onTapQuiz,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Colors.deepPurple, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Quiz",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}