import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme_provider.dart';

class DeleteLessonScreen extends StatefulWidget {
  const DeleteLessonScreen({super.key});

  @override
  State<DeleteLessonScreen> createState() => _DeleteLessonScreenState();
}

class _DeleteLessonScreenState extends State<DeleteLessonScreen> {
  final String apiUrl = "http://109.199.120.38:8001";
  List<dynamic> lessons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$apiUrl/get_lessons'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          lessons = data['lessons'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Connection error: $e", Colors.red);
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteLesson(int lessonId, int index) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/delete-lesson/$lessonId'));
      if (response.statusCode == 200) {
        setState(() {
          lessons.removeAt(index);
        });
        _showSnackBar("Lesson and associated quiz removed", Colors.green);
      } else {
        _showSnackBar("Failed to delete from server", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Server unreachable", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _fetchLessons,
        color: Colors.deepPurple,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: true,
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Manage Content", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                background: Container(color: Colors.deepPurple),
              ),
            ),
            
            isLoading 
              ? SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.deepPurple))
                )
              : lessons.isEmpty 
                  ? _buildEmptyState(isDark)
                  : SliverPadding(
                      padding: const EdgeInsets.all(15),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final lesson = lessons[index];
                            return _buildLessonCard(lesson, index, isDark);
                          },
                          childCount: lessons.length,
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(dynamic lesson, int index, bool isDark) {
    // Check if a quiz exists for this lesson
    bool hasQuiz = lesson['quiz_file'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: isDark ? Border.all(color: Colors.white10, width: 1) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            ),
            if (hasQuiz)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  child: const Icon(Icons.quiz, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Text(
          lesson['title'] ?? 'Untitled',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Category: ${lesson['category'] ?? 'N/A'}",
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
            ),
            if (hasQuiz)
              const Text(
                "✓ Quiz attached",
                style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
          onPressed: () => _confirmDelete(lesson['id'], index, lesson['title'], isDark),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, 
              size: 80, 
              color: isDark ? Colors.white24 : Colors.grey[400]
            ),
            const SizedBox(height: 16),
            Text("No content found.", 
              style: TextStyle(
                fontSize: 18, 
                color: isDark ? Colors.white38 : Colors.grey
              )
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id, int index, String title, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Content?", 
          style: TextStyle(color: isDark ? Colors.white : Colors.black87)
        ),
        content: Text(
          "Warning: Deleting '$title' will also permanently delete its associated Quiz PDF from the server folders.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white70 : Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteLesson(id, index);
            },
            child: const Text("Delete Everything", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}