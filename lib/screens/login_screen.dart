import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'homeadmins-screen.dart'; // Ensure this file exists

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool isLoading = false;
  bool obscurePassword = true;

// ... imports stay the same

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      // --- ADMIN REDIRECT LOGIC ---
      bool isAdmin1 = email == "k@gmail.com" && password == "000000";
      bool isAdmin2 = email == "chijioke@gmail.com" && password == "emmanuel";

      if (isAdmin1 || isAdmin2) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // ADDED: Save login timestamp
        await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
        
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', 'admin');
        await prefs.setString('userName', isAdmin1 ? "Kwete Junior" : "Chijioke");
        await prefs.setString('user email', isAdmin1 ? "K@gmail.com" : "Chijioke@gmail.com");

        if (mounted) {
          _showSnackBar("Admin Access Granted", Colors.blue.shade700);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeAdminsScreen()),
          );
        }
        return; 
      }
      // --- END ADMIN REDIRECT ---

      const String baseUrl = "http://109.199.120.38:8001"; 
      final url = Uri.parse("$baseUrl/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 5));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // ADDED: Save login timestamp for students
        await prefs.setString('login_timestamp', DateTime.now().toIso8601String());

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', 'student');
        await prefs.setString('userName', data['user']?['fullname'] ?? "User");
        await prefs.setString('userEmail', data['user']?['email'] ?? "");

        if (mounted) {
          _showSnackBar("Login Successful!", Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        _showSnackBar(data['message'] ?? "Invalid email or password", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection error: Check API status", Colors.orange);
      debugPrint("Login Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

// ... rest of the file stays the same}

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'logo',
                child: Icon(Icons.school, size: 80, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back 👋",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text("Login to continue learning"),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => (value == null || !value.contains("@")) 
                          ? "Enter a valid email" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6) 
                          ? "Password must be at least 6 characters" : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const SignUpScreen())
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}