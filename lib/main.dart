import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  // We move everything inside the App to prevent startup hanging
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'Smart Tutor',
      debugShowCheckedModeBanner: false,
      // Defaulting to light for testing stability
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      // We pass 'false' manually just to see if the screen loads
      home: const SplashScreen(isLoggedIn: false),
    );
  }
}