import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart'; 
import 'package:path_provider/path_provider.dart'; 
import '../theme_provider.dart';
import 'note_page.dart'; 
import 'quiz_screen.dart';

class LessonPage extends StatelessWidget {
  final String subjectId;
  final String title;

  const LessonPage({
    super.key,
    required this.subjectId,
    required this.title
  });

  // --- UPDATED DOWNLOAD LOGIC ---
  Future<void> _downloadAndOpenPDF(BuildContext context, bool isViewOnly) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      // FIX: Matches your VPS folder structure and port 8001
      // Path: http://IP:8001/pdfs/SubjectName/SubjectName.pdf
      String url = "http://109.199.120.38:8001/pdfs/$subjectId/$subjectId.pdf"; 
      
      Directory tempDir = await getApplicationDocumentsDirectory();
      String fullPath = "${tempDir.path}/$subjectId.pdf";

      await Dio().download(url, fullPath);

      if (context.mounted) Navigator.pop(context); // Close loading dialog

      if (isViewOnly) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotePage(pdfPath: fullPath, title: title),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ PDF Downloaded Successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: Could not fetch PDF. Ensure the file exists in 'assert lessons/$subjectId/'")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Study Options", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.deepPurple,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: isDark ? Colors.deepPurple.withOpacity(0.3) : Colors.white24,
                  child: const Icon(Icons.menu_book, size: 45, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              children: [
                _buildMenuButton(
                  context,
                  "VIEW PDF NOTES",
                  Icons.picture_as_pdf,
                  isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                  () => _downloadAndOpenPDF(context, true), 
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  "DOWNLOAD PDF",
                  Icons.download,
                  isDark ? Colors.blueGrey.shade700 : Colors.blueGrey,
                  () => _downloadAndOpenPDF(context, false), 
                ),
                const SizedBox(height: 16),
                
                _buildMenuButton(
                  context,
                  "PRACTICE QUIZ",
                  Icons.quiz,
                  isDark ? Colors.orange.shade900 : Colors.orange.shade800,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          lessonId: subjectId, 
                          subjectId: subjectId, 
                        ),
                      ),
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

  Widget _buildMenuButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}