import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/lesson.dart';
import '../services/ai_service.dart';
import '../theme_provider.dart';
import 'quiz_screen.dart';
import 'lesson_page.dart'; // ADDED: Import to allow navigation to detail page

class LessonScreen extends StatefulWidget {
  final String subjectId;

  const LessonScreen({super.key, required this.subjectId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isLoadingAI = false;
  String _aiResponse = "";
  late Future<List<Lesson>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _refreshLessons(); // Initial fetch
  }

  // Fetches data from VPS and maps it to Lesson models
  Future<List<Lesson>> _fetchLessonsFromVPS() async {
    try {
      final response = await Dio().get("http://109.199.120.38:8001/get_lessons");
      if (response.data['success']) {
        List data = response.data['lessons'];
        
        return data
            .map((json) => Lesson.fromJson(json))
            .where((lesson) => lesson.category.toLowerCase() == widget.subjectId.toLowerCase())
            .toList();
      }
    } catch (e) {
      print("Error: $e");
    }
    return [];
  }

  Future<void> _refreshLessons() async {
    setState(() {
      _lessonsFuture = _fetchLessonsFromVPS();
    });
  }

  Future<void> _generateAILesson() async {
    setState(() {
      _isLoadingAI = true;
      _aiResponse = "";
    });
    try {
      final result = await AIService.generateLessonContent(widget.subjectId);
      setState(() => _aiResponse = result);
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text("${widget.subjectId.toUpperCase()} Materials"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshLessons),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLessons,
        color: Colors.deepPurple,
        child: FutureBuilder<List<Lesson>>(
          future: _lessonsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final lessons = snapshot.data ?? [];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAICard(themeProvider),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Available Papers",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text("${lessons.length} Files",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- DYNAMIC LIST OF PAPERS ---
                  lessons.isEmpty
                      ? _buildEmptyState(themeProvider.isDarkMode)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lessons.length,
                          itemBuilder: (context, index) {
                            return _buildLessonPaperTile(
                                lessons[index], index, themeProvider);
                          },
                        ),

                  const SizedBox(height: 20),
                  if (lessons.isNotEmpty) _buildStartQuizButton(lessons),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoadingAI ? null : _generateAILesson,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(_isLoadingAI ? "Thinking..." : "AI Deep Dive",
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.folder_open, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text("No PDF materials found yet.",
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // --- UPDATED WIDGET: NOW PUSHES TO LESSON PAGE ---
  Widget _buildLessonPaperTile(Lesson lesson, int index, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        ),
        title: Text(lesson.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip("Approved", Colors.green),
                const SizedBox(width: 8),
                _buildStatusChip("Exam Prep", Colors.orange),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        
        // --- NAVIGATION LOGIC UPDATED ---
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonPage(
                subjectId: widget.subjectId, // Passing e.g. 'physics'
                title: lesson.title,         // Passing the paper name
              ),
            ),
          );
        },
      ),
    );
  }

  // ... (Other widgets like _buildAICard, _buildStatusChip, etc. stay the same)

  Widget _buildStartQuizButton(List<Lesson> lessons) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                subjectId: widget.subjectId,
                lessonId: lessons.isNotEmpty ? lessons[0].id : '',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: const Text(
          "Master This Topic (Start Quiz)",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAICard(ThemeProvider theme) {
    return Card(
      elevation: 0,
      color: Colors.deepPurple.withOpacity(theme.isDarkMode ? 0.2 : 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_aiResponse.isEmpty) ...[
              const Icon(Icons.auto_stories_outlined, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 8),
              const Text("Unlock AI Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Text("Get a detailed summary of this topic instantly.", textAlign: TextAlign.center),
            ] else
              MarkdownBody(
                data: _aiResponse,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 15, color: theme.isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}