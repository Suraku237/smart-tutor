import 'package:flutter/material.dart';
import 'login_screen.dart'; // make sure you create login screen later

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeText = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // AUTOMATIC NAVIGATION AFTER 3 SECONDS
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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
      backgroundColor: Colors.deepPurple,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // LOGO ANIMATION
            ScaleTransition(
              scale: _logoScale,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.deepPurple,
                  size: 70,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // APP NAME
            FadeTransition(
              opacity: _fadeText,
              child: const Text(
                "SmartTutor",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TAGLINE
            FadeTransition(
              opacity: _fadeText,
              child: Text(
                "Learn smarter, not harder",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
