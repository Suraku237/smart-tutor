import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/lesson.dart';
import '../services/dummy_data.dart';
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
    List<Lesson> lessons = DummyData.lessons[widget.subjectId] ?? [];

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text("${widget.subjectId.toUpperCase()} Materials"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAICard(themeProvider),
            const SizedBox(height: 25),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Papers",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("View All",
                    style: TextStyle(
                        color: Colors.deepPurple, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 15),

            // --- LIST OF PAPERS ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                return _buildLessonPaperTile(
                    lessons[index], index, themeProvider);
              },
            ),

            const SizedBox(height: 20),
            _buildStartQuizButton(lessons),
            const SizedBox(height: 80),
          ],
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