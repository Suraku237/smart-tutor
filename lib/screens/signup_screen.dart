import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePass = true;
  bool obscureConfirmPass = true;

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Using your local Ethernet IP and port 8001
      const String baseUrl = "http://109.199.120.38:8001"; 

      final url = Uri.parse("$baseUrl/signup");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "fullname": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        if (mounted) {
          _showSnackBar("Account created successfully!", Colors.green);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        _showError(data['message'] ?? "Registration failed");
      }
    } catch (e) {
      _showError("Connection error. Check Wi-Fi & ensure Python API is running.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    _showSnackBar(message, Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: color, 
        behavior: SnackBarBehavior.floating
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'logo',
                child: Icon(Icons.school_outlined, size: 80, color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),
              const Text("Create Account ✨", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Join SmartTutor and start learning smarter"),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // FULL NAME
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline), 
                        labelText: "Full Name", 
                        border: OutlineInputBorder(), 
                        filled: true, 
                        fillColor: Colors.white
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Name is required" : null,
                    ),
                    const SizedBox(height: 15),

                    // EMAIL
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined), 
                        labelText: "Email Address", 
                        border: OutlineInputBorder(), 
                        filled: true, 
                        fillColor: Colors.white
                      ),
                      validator: (value) => (value == null || !value.contains("@")) ? "Invalid email format" : null,
                    ),
                    const SizedBox(height: 15),

                    // PASSWORD - UPDATED WITH LENGTH LIMITS
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePass,
                      maxLength: 1000, // Hard limit to prevent Bcrypt error
                      decoration: InputDecoration(
                        counterText: "", // Hides character count
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(obscurePass ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => obscurePass = !obscurePass),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) return "Minimum 6 characters";
                        if (value.length > 1000) return "Password too long (max 1000)";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // CONFIRM PASSWORD - UPDATED WITH LENGTH LIMITS
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPass,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        labelText: "Confirm Password",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirmPass ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => obscureConfirmPass = !obscureConfirmPass),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Please confirm your password";
                        if (value != passwordController.text) return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text("Login", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}