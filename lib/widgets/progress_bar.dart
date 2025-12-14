import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;

  const ProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (currentIndex + 1) / totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Progress: ${(progress * 100).toStringAsFixed(0)}%",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        // ANIMATED PROGRESS BAR
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: MediaQuery.of(context).size.width * progress,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Background bar
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
