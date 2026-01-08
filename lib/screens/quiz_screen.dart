import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../widgets/progress_bar.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;
  final String subjectId; // Make sure you're passing this

  const QuizScreen({
    super.key, 
    required this.lessonId, 
    required this.subjectId, // Add this parameter
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {

  List<Quiz> quizzes = [];
  int currentIndex = 0;
  int score = 0;

  // TIMER
  int timeLeft = 15;
  Timer? countdownTimer;
  bool timeUp = false;

  // ANIMATION CONTROLLERS
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    // FIX: Use the correct method to get quizzes
    // Option 1: Use getQuizzesByLesson (if it's working)
    //quizzes = DummyData.getQuizzesByLesson(widget.lessonId);
    
    // Debug print to check if quizzes are loaded
    print("Quizzes loaded: ${quizzes.length}");
    print("Lesson ID: ${widget.lessonId}");
    print("Subject ID: ${widget.subjectId}");

    // Check if quizzes are empty before proceeding
    if (quizzes.isEmpty) {
      print("ERROR: No quizzes found for ${widget.lessonId}");
      // You might want to show an error message or navigate back
    }

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    //startTimer();
    controller.forward();
  }

  // ... rest of your code ...

  @override
  Widget build(BuildContext context) {
    // CHECK if quizzes is empty before accessing it
    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Quiz"),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                SizedBox(height: 20),
                Text(
                  "No quizzes available for this subject.",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Only access currentQuiz if quizzes is not empty

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROGRESS BAR
            ProgressBar(
              currentIndex: currentIndex,
              totalQuestions: quizzes.length,
            ),
            
            // ... rest of your quiz UI code ...
          ],
        ),
      ),
    );
  }
}