import 'package:flutter/material.dart';

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
        title: const Text("Study Options"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                  radius: 45,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.menu_book, size: 45, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 22, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // --- ACTION BUTTONS SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              children: [
                // 1. VIEW PDF (Primary Action)
                _buildMenuButton(
                  context, 
                  "VIEW PDF NOTES", 
                  Icons.picture_as_pdf, 
                  Colors.deepPurple,
                  () { /* PDF View Logic */ }
                ),
                
                const SizedBox(height: 16),

                // 2. DOWNLOAD (Secondary Action)
                _buildMenuButton(
                  context, 
                  "DOWNLOAD PDF", 
                  Icons.download, 
                  Colors.blueGrey,
                  () { /* Download Logic */ }
                ),

                const SizedBox(height: 16),

                // 3. PRACTICE QUIZ (Gamified Action)
                _buildMenuButton(
                  context, 
                  "PRACTICE QUIZ", 
                  Icons.quiz, 
                  Colors.orange.shade800,
                  () { /* Quiz Logic */ }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper with specific size constraints
  Widget _buildMenuButton(
    BuildContext context, 
    String label, 
    IconData icon, 
    Color color, 
    VoidCallback onTap
  ) {
    return SizedBox(
      width: double.infinity, // Makes button span the width of the padding
      height: 60,            // Fixed height for consistency
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}