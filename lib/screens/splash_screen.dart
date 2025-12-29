import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _fadeText;

  @override
  void initState() {
    super.initState();

    // 1. Initialize animations to match the premium "Smart" feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeText = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
Future.delayed(const Duration(seconds: 3), () {
  if (mounted) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder( // Removed 'const'
        pageBuilder: (context, animation, secondaryAnimation) =>const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using the same Deep Purple from your LessonScreen AppBar
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO: Matches the school icon from your Lesson Tiles
            ScaleTransition(
              scale: _logoScale,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.deepPurple,
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // APP NAME
            FadeTransition(
              opacity: _fadeText,
              child: const Text(
                "SMART TUTOR",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TAGLINE: No 'const' here to avoid Windows build errors with withOpacity
            FadeTransition(
              opacity: _fadeText,
              child: Text(
                "AI-Powered Learning Excellence",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}