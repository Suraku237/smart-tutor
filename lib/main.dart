import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding.dart';
// ignore: unused_import
import 'screens/home_screen.dart';


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
        '/home': (context) => const HomePage(),
      },
    );
  }
}

