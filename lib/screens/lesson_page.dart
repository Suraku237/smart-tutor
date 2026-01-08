import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:smartproject/screens/note_page.dart';
import 'package:smartproject/theme_provider.dart';

class LessonPage extends StatefulWidget {
  final String subjectId; // This acts as our Category filter
  final String title;

  const LessonPage({super.key, required this.subjectId, required this.title});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late Future<List<dynamic>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _fetchLessons();
  }

  Future<List<dynamic>> _fetchLessons() async {
    try {
      // Fetching only lessons that match this subject/category
      final response = await Dio().get("http://109.199.120.38:8001/get_lessons");
      if (response.data['success']) {
        List allLessons = response.data['lessons'];
        // Filter lessons by the current subjectId (Category)
        return allLessons.where((l) => l['category'] == widget.subjectId).toList();
      }
      } catch (e) {
        debugPrint("Fetch Error: $e");
      }
      return [];
    }

    Future<void> _downloadAndOpenPDF(BuildContext context, String category, String title, bool isViewOnly) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      // Matches: http://109.199.120.38:8001/assert%20lessons/Math/Algebra.pdf
      String folder = Uri.encodeComponent(category);
      String file = Uri.encodeComponent(title);

      String url = "http://109.199.120.38:8001/pdfs/$folder/$file.pdf";
      print("Requesting URL: $url"); // Check this output in your Flutter console!

      Directory tempDir = await getApplicationDocumentsDirectory();
      String fullPath = "${tempDir.path}/${title.replaceAll(' ', '_')}.pdf";

      await Dio().download(url, fullPath);

      if (context.mounted) Navigator.pop(context); // Close loading dialog

      if (isViewOnly) {
        // Navigate to your PDF Viewer page
        Navigator.push(context, MaterialPageRoute(builder: (context) => NotePage(pdfPath: fullPath, title: title)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ PDF Saved to Documents")));
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error fetching PDF: $e")));
      debugPrint("❌ Error fetching PDF: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.deepPurple : Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final lesson = snapshot.data![index];
              return _buildLessonCard(context, lesson, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, dynamic lesson, bool isDark) {
    String lessonTitle = lesson['title'];
    String category = lesson['category'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: ExpansionTile(
        leading: const Icon(Icons.menu_book, color: Colors.deepPurple),
        title: Text(lessonTitle, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text("PDF Lesson Notes", style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildActionButton(context, "VIEW PDF NOTES", Icons.picture_as_pdf, Colors.deepPurple, 
                  () => _downloadAndOpenPDF(context, category, lessonTitle, true)),
                const SizedBox(height: 10),
                _buildActionButton(context, "DOWNLOAD PDF", Icons.download, Colors.blueGrey, 
                  () => _downloadAndOpenPDF(context, category, lessonTitle, false)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: isDark ? Colors.grey : Colors.grey.shade400),
          const SizedBox(height: 10),
          Text("No lessons added yet for ${widget.title}", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}