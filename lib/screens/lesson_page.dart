import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart'; // Add Dio for downloads
import 'package:path_provider/path_provider.dart'; // Add for file storage
import '../theme_provider.dart';
import 'note_page.dart'; // Import your new NotePage

class LessonPage extends StatelessWidget {
  final String subjectId;
  final String title;

  const LessonPage({
    super.key,
    required this.subjectId,
    required this.title
  });

  // --- DOWNLOAD LOGIC ---
  Future<void> _downloadAndOpenPDF(BuildContext context, bool isViewOnly) async {
    try {
      // Show a loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      // 1. Define the URL (Replace with your VPS IP and actual PDF path)
      String url = "http://109.199.120.38/pdfs/$subjectId.pdf"; 
      
      // 2. Get the local storage path
      Directory tempDir = await getApplicationDocumentsDirectory();
      String fullPath = "${tempDir.path}/$subjectId.pdf";

      // 3. Download the file
      await Dio().download(url, fullPath);

      // Close loading dialog
      Navigator.pop(context);

      if (isViewOnly) {
        // 4. Open the NotePage
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
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: Could not fetch PDF. $e")),
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
                  () => _downloadAndOpenPDF(context, true), // VIEW
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  "DOWNLOAD PDF",
                  Icons.download,
                  isDark ? Colors.blueGrey.shade700 : Colors.blueGrey,
                  () => _downloadAndOpenPDF(context, false), // DOWNLOAD ONLY
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  "PRACTICE QUIZ",
                  Icons.quiz,
                  isDark ? Colors.orange.shade900 : Colors.orange.shade800,
                  () { /* Quiz Logic */ }
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