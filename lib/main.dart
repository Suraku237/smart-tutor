// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SmartTutorApp());
}

class SmartTutorApp extends StatelessWidget {
  const SmartTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Tutor',
      debugShowCheckedModeBanner: false,
      
      // App Theme
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 3,
          centerTitle: true,
        ),
      ),

      // First screen to load
      home: const SplashScreen(),
    );
  }
}