import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/lesson.dart';
import '../services/dummy_data.dart';
import '../services/ai_service.dart';
import '../theme_provider.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final String subjectId;

  const LessonScreen({super.key, required this.subjectId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isLoadingAI = false;
  String _aiResponse = "";

  // --- PDF GENERATION LOGIC ---
  Future<void> _exportToPDF(String title, String content) async {
    if (content.isEmpty) return;
    
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(content, style: const pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}.pdf',
    );
  }

  // --- AI GENERATION LOGIC ---
  Future<void> _generateAILesson() async {
    setState(() {
      _isLoadingAI = true;
      _aiResponse = "";
    });

    try {
      final result = await AIService.generateLessonContent(widget.subjectId);
      setState(() => _aiResponse = result);
    } catch (e) {
      setState(() => _aiResponse = "Error generating AI content: $e");
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // SAFE DATA FETCHING: Prevents crash if the subject ID doesn't exist in DummyData
    final List<Lesson> lessons = DummyData.lessons[widget.subjectId] ?? [];

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text("${widget.subjectId.toUpperCase()} Materials"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: lessons.isEmpty && _aiResponse.isEmpty && !_isLoadingAI
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAICard(themeProvider),
                  const SizedBox(height: 25),
                  const Text(
                    "Recent Papers", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 15),
                  
                  // PDF LIST SECTION
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      return _buildLessonPaperTile(lessons[index], themeProvider);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // QUIZ BUTTON: Only enabled if lessons exist
                  _buildStartQuizButton(lessons),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoadingAI ? null : _generateAILesson,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          _isLoadingAI ? "Thinking..." : "AI Deep Dive", 
          style: const TextStyle(color: Colors.white)
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildEmptyState() {
    return const Center(
      child: Text("No materials found. Try the AI Deep Dive!"),
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
            if (_aiResponse.isEmpty && !_isLoadingAI) ...[
              const Icon(Icons.auto_stories_outlined, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 8),
              const Text("Unlock AI Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Text("Get a detailed summary of this topic instantly.", textAlign: TextAlign.center),
            ] else if (_isLoadingAI) ...[
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 10),
              const Text("AI is preparing your lesson..."),
            ] else ...[
              MarkdownBody(
                data: _aiResponse,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => _exportToPDF("AI Summary: ${widget.subjectId}", _aiResponse),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text("Save as PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLessonPaperTile(Lesson lesson, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 5, 
            offset: const Offset(0, 2)
          )
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Module ${lesson.id}"),
        trailing: const Icon(Icons.download_rounded, color: Colors.deepPurple),
        onTap: () => _exportToPDF(lesson.title, lesson.content),
      ),
    );
  }

  Widget _buildStartQuizButton(List<Lesson> lessons) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: lessons.isEmpty 
            ? null 
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      subjectId: widget.subjectId,
                      lessonId: lessons[0].id,
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "Master This Topic (Start Quiz)",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}