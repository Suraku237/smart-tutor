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

      // App Theme (You can change colors later)
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
      ),

      // First screen to load
      home: SplashScreen(),
    );
  }
}