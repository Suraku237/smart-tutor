import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class QuizScreen extends StatefulWidget {
  final String subjectId; // e.g., 'physics'
  final String lessonId;  // The ID used to find the specific quiz

  const QuizScreen({
    super.key,
    required this.subjectId,
    required this.lessonId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _localPath;
  bool _isLoading = true;
  String _errorMessage = "";
  int _totalPages = 0;
  int _currentPage = 0;
  bool _pdfReady = false;

  @override
  void initState() {
    super.initState();
    _fetchAndDownloadQuiz();
  }

  // --- LOGIC TO FETCH PDF FROM YOUR VPS ---
  Future<void> _fetchAndDownloadQuiz() async {
    try {
      // Construction of the URL based on your VPS structure
      // Example: http://109.199.120.38:8001/get_quiz/physics/lesson_id
      final String url = "http://109.199.120.38:8001/get_quiz/${widget.subjectId}/${widget.lessonId}";
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/quiz_${widget.lessonId}.pdf");
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "No quiz found for this lesson.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection error: Unable to reach server.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text("${widget.subjectId.toUpperCase()} Quiz"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          else if (_errorMessage.isNotEmpty)
            _buildErrorState()
          else
            PDFView(
              filePath: _localPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onRender: (pages) => setState(() {
                _totalPages = pages!;
                _pdfReady = true;
              }),
              onPageChanged: (page, total) => setState(() {
                _currentPage = page!;
              }),
              onError: (error) => setState(() => _errorMessage = error.toString()),
            ),

          // Floating Page Indicator
          if (_pdfReady && _errorMessage.isEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Page ${_currentPage + 1} / $_totalPages",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("Go Back", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}