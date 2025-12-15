// lib/screens/quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/dummy_data.dart';
import '../widgets/progress_bar.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;
  final String subjectId;

  const QuizScreen({
    super.key, 
    required this.lessonId, 
    required this.subjectId,
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

    // Get quizzes by subjectId
    quizzes = DummyData.quizzes[widget.subjectId] ?? [];
    
    // Debug print
    print("Quizzes loaded: ${quizzes.length}");
    print("Subject ID: ${widget.subjectId}");

    // Check if quizzes are empty
    if (quizzes.isEmpty) {
      print("ERROR: No quizzes found for ${widget.subjectId}");
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

    startTimer();
    controller.forward();
  }

  void startTimer() {
    timeLeft = 15;
    timeUp = false;

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
        setState(() => timeUp = true);
        countdownTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 800), nextQuestion);
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void restartAnimations() {
    controller.reset();
    controller.forward();
  }

  void checkAnswer(int selectedIndex) {
    if (timeUp) return;

    bool correct = quizzes[currentIndex].correctIndex == selectedIndex;

    if (correct) score++;

    setState(() {
      timeUp = true;
      timeLeft = 0;
    });

    countdownTimer?.cancel();

    Future.delayed(const Duration(milliseconds: 800), nextQuestion);
  }

  void nextQuestion() {
    if (currentIndex < quizzes.length - 1) {
      setState(() {
        currentIndex++;
      });
      restartAnimations();
      startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            total: quizzes.length,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if quizzes is empty
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
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  "No quizzes available for this subject.",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Quiz currentQuiz = quizzes[currentIndex];

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

            const SizedBox(height: 20),

            // TIMER WITH PULSE EFFECT
            AnimatedScale(
              scale: timeLeft <= 5 ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: timeUp
                      ? Colors.red
                      : timeLeft <= 5
                          ? Colors.orange
                          : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  timeUp ? "⏳ Time's Up!" : "⏱ Time Left: $timeLeft sec",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            

            const SizedBox(height: 30),

            // QUESTION - FADE IN
            FadeTransition(
              opacity: fadeAnimation,
              child: Text(
                "Q${currentIndex + 1}. ${currentQuiz.question}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // OPTIONS - SLIDE UP ANIMATION
            FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Column(
                  children: List.generate(
                    currentQuiz.options.length,
                    (index) => GestureDetector(
                      onTap: () => checkAnswer(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0, 2),
                              blurRadius: 3,
                              color: Colors.black12,
                            )
                          ],
                        ),
                        child: Text(
                          currentQuiz.options[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}