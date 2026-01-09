import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteLessonScreen extends StatefulWidget {
  const DeleteLessonScreen({super.key});

  @override
  State<DeleteLessonScreen> createState() => _DeleteLessonScreenState();
}

class _DeleteLessonScreenState extends State<DeleteLessonScreen> {
  // Use your actual VPS URL
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
        _showSnackBar("Lesson permanently removed", Colors.green);
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _fetchLessons,
        color: Colors.deepPurple,
        child: CustomScrollView(
          slivers: [
            // Modern Animated Header
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.deepPurple,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Manage Lessons", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                background: Container(color: Colors.deepPurple),
              ),
            ),
            
            // Body Content
            isLoading 
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : lessons.isEmpty 
                  ? _buildEmptyState()
                  : SliverPadding(
                      padding: const EdgeInsets.all(15),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final lesson = lessons[index];
                            return _buildLessonCard(lesson, index);
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

  Widget _buildLessonCard(dynamic lesson, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
        ),
        title: Text(
          lesson['title'] ?? 'Untitled',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Category: ${lesson['category'] ?? 'N/A'}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
          onPressed: () => _confirmDelete(lesson['id'], index, lesson['title']),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("No lessons found.", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id, int index, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Permanent Delete?"),
        content: Text("Are you sure you want to delete '$title'? This will remove the file from the server."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteLesson(id, index);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}