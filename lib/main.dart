import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this
import 'theme_provider.dart';           // Add this
import 'screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const SmartTutorApp(),
    ),
  );
}

class SmartTutorApp extends StatelessWidget {
  const SmartTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the theme state
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Smart Tutor',
      debugShowCheckedModeBanner: false,
      
      // Theme logic
      themeMode: themeProvider.themeMode,
      
      // Light Mode Settings
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),

      // Dark Mode Settings
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep Black
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}