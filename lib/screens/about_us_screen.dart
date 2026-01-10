import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("About the Team", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: THE DEVELOPERS ---
            _buildSectionTitle("The Developers", isDark),
            const SizedBox(height: 15),
            _buildDevTile(
              name: "kwete junior",
              role: "Full-Stack & DevOps Engineer",
              contribution: "Architected the FastAPI backend, managed the VPS deployment, and integrated the MySQL database and AI processing logic.",
              icon: Icons.storage_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 15),
            _buildDevTile(
              name: "chijioke emmanuel",
              role: "Lead Mobile Developer",
              contribution: "Designed the Flutter UI/UX, implemented Theme Management, and developed the PDF rendering and client-side API integration.",
              icon: Icons.phone_android_rounded,
              isDark: isDark,
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // --- SECTION 2: HOW WE DEVELOPED THE SYSTEM ---
            _buildSectionTitle("How We Built SmartTutor", isDark),
            const SizedBox(height: 15),
            _buildProcessStep(
              "1", "Architecture", 
              "We chose a decoupled architecture using FastAPI for high performance and Flutter for a smooth cross-platform experience.",
              isDark
            ),
            _buildProcessStep(
              "2", "Cloud Infrastructure", 
              "The system is hosted on a private VPS, ensuring fast PDF delivery and secure user data management via a custom MySQL instance.",
              isDark
            ),
            _buildProcessStep(
              "3", "AI & Integration", 
              "We integrated advanced NLP models to summarize lessons and provide feedback, bridging the gap between static content and interactive learning.",
              isDark
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Version 1.0.0 • © 2026 SmartTutor Team",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
      ),
    );
  }

  // Helper for Developer Cards
  Widget _buildDevTile({required String name, required String role, required String contribution, required IconData icon, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
                Text(role, style: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(contribution, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Process Steps
  Widget _buildProcessStep(String number, String title, String description, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.deepPurple,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}