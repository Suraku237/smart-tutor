import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String emoji;
  final String title;
  final VoidCallback onTapLesson;
  final VoidCallback onTapQuiz;

  const LessonCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.onTapLesson,
    required this.onTapQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          // EMOJI
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          
          const SizedBox(height: 4),
          
          // TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // BUTTONS ROW (instead of column to save vertical space)
          Row(
            children: [
              // LESSON BUTTON - takes half width
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: ElevatedButton(
                    onPressed: onTapLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Lesson",
                      style: TextStyle(fontSize: 12), // Reduced
                    ),
                  ),
                ),
              ),
              
              // QUIZ BUTTON - takes half width
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: OutlinedButton(
                    onPressed: onTapQuiz,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced
                      side: const BorderSide(color: Colors.deepPurple, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Quiz",
                      style: TextStyle(
                        fontSize: 12, // Reduced
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