// Importing Flutter's Material package for UI components and themes
import 'package:flutter/material.dart';

// Entry point of the Flutter app
void main() {
  runApp(const MyApp()); // Runs the root widget (MyApp)
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor with optional key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMART TUTOR Login', // App title
      debugShowCheckedModeBanner: false, // Removes debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets primary color theme
        scaffoldBackgroundColor: Colors.white, // Background color for screens
      ),
      home: const LoginPage(), // Sets the initial screen
    );
  }
}

// Login page widget (stateful since user input changes state)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// State class for LoginPage
class _LoginPageState extends State<LoginPage> {
  // Controllers to capture user input from text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to handle login logic
  void _login() {
    // Get and trim text from input fields
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();

    // Check if either field is empty
    if (name.isEmpty || password.isEmpty) {
      // Show error message if inputs are missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both name and password"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      // Show welcome message if inputs are valid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome, $name!"),
          backgroundColor: Colors.blueAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main page layout structure
      body: Center(
        // Centers the login form on the screen
        child: Container(
          // Adds a background image to the container
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('Assert/home.png'), // Background image path
              fit: BoxFit.cover, // Makes image cover full area
            ),
          ),
          child: Padding(
            // Adds padding around content
            padding: const EdgeInsets.all(24.0),
            child: Column(
              // Vertically aligns children widgets
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title text
                const Text(
                  "SMART TUTOR Login",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40), // Spacing between widgets

                // Name input field
                TextField(
                  controller: _nameController, // Connects to controller
                  decoration: const InputDecoration(
                    labelText: "Name", // Label text
                    prefixIcon: Icon(Icons.person), // Person icon
                    border: OutlineInputBorder(), // Adds border
                  ),
                ),
                const SizedBox(height: 16), // Space between fields

                // Password input field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock), // Lock icon
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Hides input for password
                ),
                const SizedBox(height: 24), // Space before login button

                // Login button
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: _login, // Calls login function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button color
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // White text on button
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
