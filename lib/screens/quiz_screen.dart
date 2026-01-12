import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class QuizScreen extends StatefulWidget {
  final String subjectId;
  final String lessonTitle; // This must match the title used during Admin upload
  final String category; // <--- Add this

  const QuizScreen({
    super.key,
    required this.subjectId,
    required this.lessonTitle,
    required this.category, // <--- Add this
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

  @override
  void initState() {
    super.initState();
    _downloadAndShowPdf();
  }

  Future<void> _downloadAndShowPdf() async {
    try {
      // Construction matches your Admin logic: quiz_TitleName.pdf
    final String fileName = "quiz_${widget.lessonTitle}.pdf";
    
    // We point to the STATIC mount you created: /quizzes/Category/FileName
    final String url = "http://109.199.120.38:8001/quizzes/${Uri.encodeComponent(widget.category)}/${Uri.encodeComponent(fileName)}";

    print("📡 Fetching Quiz from: $url"); // Debug print

    final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        // Create a unique path to avoid showing the wrong quiz from cache
        final file = File("${dir.path}/quiz_view_${widget.lessonTitle.hashCode}.pdf");
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Quiz file not found on server.\n(Expected: $fileName)";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection Error: Check your internet.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage.isNotEmpty
                ? _buildErrorState(isDark)
                : _buildPdfViewer(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.deepPurple),
        const SizedBox(height: 20),
        Text("Loading Quiz PDF...", style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPdfViewer() {
    return Stack(
      children: [
        PDFView(
          filePath: _localPath,
          enableSwipe: true,
          swipeHorizontal: false, // Standard for exam papers
          autoSpacing: true,
          pageFling: true,
          onRender: (pages) => setState(() => _totalPages = pages!),
          onPageChanged: (page, total) => setState(() => _currentPage = page!),
          onError: (error) => setState(() => _errorMessage = error.toString()),
        ),
        // Floating Page Counter
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Page ${_currentPage + 1} / $_totalPages",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_outlined, size: 60, color: Colors.red[300]),
          const SizedBox(height: 10),
          Text(_errorMessage, textAlign: TextAlign.center, 
               style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Go Back"),
          )
        ],
      ),
    );
  }
}