import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  final String subject;

  const LessonsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    List<String> lessons = [
      "Introduction",
      "Chapter 1: Basics",
      "Chapter 2: Intermediate",
      "Chapter 3: Advanced",
      "Practice Quiz",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          subject,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            return lessonCard(lessons[index], index, context);
          },
        ),
      ),
    );
  }

  Widget lessonCard(String title, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to lesson videos or quiz
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),

            // Lesson Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
