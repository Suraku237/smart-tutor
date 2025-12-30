import 'package:flutter/material.dart';
import 'lesson_screen.dart'; // Ensure this path is correct

class LessonPage extends StatelessWidget {
  final String subjectId; 
  final String title;     

  const LessonPage({
    super.key, 
    required this.subjectId, 
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        // Manual back button for clarity
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.menu_book, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Select an option below to begin your study session. All materials are updated weekly from our online database.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                _buildMenuButton(
                  context, 
                  "READ PDF NOTES", 
                  Icons.picture_as_pdf, 
                  () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => LessonScreen(subjectId: subjectId))
                    );
                  }
                ),
                const SizedBox(height: 15),
                _buildMenuButton(
                  context, 
                  "PRACTICE QUIZ", 
                  Icons.quiz, 
                  () {
                    // This will be linked to your Quiz logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Quiz mode starting..."))
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}