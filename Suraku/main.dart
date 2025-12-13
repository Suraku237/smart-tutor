import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'onboarding.dart';
// ignore: unused_import
import 'login/signup_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
         '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const SignUpScreen(),
      },
    );
  }
}

