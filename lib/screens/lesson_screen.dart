import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart'; // Required for opening URLs
import '../models/lesson.dart';
import '../services/dummy_data.dart';
import '../services/ai_service.dart';
import '../theme_provider.dart';
import 'quiz_screen.dart';
import 'package:smartproject/note_service.dart'; // Your online service

class LessonScreen extends StatefulWidget {
  final String subjectId;

  const LessonScreen({super.key, required this.subjectId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final NoteService _noteService = NoteService();
  
  // States for AI and Online Notes
  bool _isLoadingAI = false;
  String _aiResponse = "";
  
  List<dynamic> _allOnlineNotes = [];
  List<dynamic> _filteredNotes = [];
  bool _isLoadingNotes = true;

  @override
  void initState() {
    super.initState();
    _fetchOnlineData();
  }

  // Fetch JSON data from your GitHub Gist
  Future<void> _fetchOnlineData() async {
    try {
      final notes = await _noteService.fetchNotesBySubject(widget.subjectId);
      setState(() {
        _allOnlineNotes = notes;
        _filteredNotes = notes;
        _isLoadingNotes = false;
      });
    } catch (e) {
      setState(() => _isLoadingNotes = false);
      debugPrint("Error fetching notes: $e");
    }
  }

  // Search Logic
  void _filterNotes(String query) {
    setState(() {
      _filteredNotes = _allOnlineNotes
          .where((note) => note['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Open PDF Logic
  Future<void> _launchPDF(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open this PDF link.")),
      );
    }
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
    List<Lesson> localLessons = DummyData.lessons[widget.subjectId] ?? [];

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text("${widget.subjectId.toUpperCase()} Materials"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAICard(themeProvider),
            const SizedBox(height: 25),

            // --- SEARCH BAR ---
            TextField(
              onChanged: _filterNotes,
              decoration: InputDecoration(
                hintText: "Search subject titles...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 25),
            const Text("Online Handouts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // --- ONLINE NOTES LIST ---
            if (_isLoadingNotes)
              const Center(child: CircularProgressIndicator())
            else if (_filteredNotes.isEmpty)
              const Text("No online notes found for this subject.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return _buildNoteItem(note, themeProvider);
                },
              ),

            const SizedBox(height: 20),
            _buildStartQuizButton(localLessons),
            const SizedBox(height: 80), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoadingAI ? null : _generateAILesson,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(_isLoadingAI ? "Thinking..." : "AI Deep Dive", style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- WIDGET: INDIVIDUAL NOTE TILE ---
  Widget _buildNoteItem(dynamic note, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        ),
        title: Text(note['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buildStatusChip(note['grade'] ?? "General", Colors.orange),
        ),
        trailing: const Icon(Icons.open_in_new, color: Colors.grey),
        
        // CLICK TO ENTER PDF
        onTap: () => _launchPDF(note['pdfUrl']),
      ),
    );
  }

  // --- HELPER UI COMPONENTS ---
  Widget _buildAICard(ThemeProvider theme) {
    return Card(
      elevation: 0,
      color: Colors.deepPurple.withOpacity(theme.isDarkMode ? 0.2 : 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoadingAI) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text("Generating study guide..."),
            ] else if (_aiResponse.isEmpty) ...[
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStartQuizButton(List<Lesson> lessons) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(
            subjectId: widget.subjectId,
            lessonId: lessons.isNotEmpty ? lessons[0].id : '',
          )));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: const Text("Master This Topic (Start Quiz)", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}