import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class NotePage extends StatefulWidget {
  final String pdfPath; // Local path to the PDF file
  final String title;   // Title of the lesson

  const NotePage({
    super.key, 
    required this.pdfPath, 
    required this.title
  });

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  int totalPages = 0;
  int currentPage = 0;
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Page Indicator in AppBar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "${currentPage + 1} / $totalPages",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false, // Vertical scrolling like a real notebook
            autoSpacing: true,
            pageFling: true,
            backgroundColor: isDark ? Colors.black : Colors.grey.shade200,
            onRender: (pages) {
              setState(() {
                totalPages = pages!;
                isReady = true;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                currentPage = page!;
              });
            },
            onError: (error) {
              print("PDF Error: ${error.toString()}");
            },
          ),
          
          // Loading Indicator until PDF is rendered
          if (!isReady)
            const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
        ],
      ),
      
      // Floating Action Buttons for Navigation
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "prev",
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            onPressed: () {
              // PDFView doesn't have a direct controller method here, 
              // but you can add a PDFViewController if you need programmatic jumps.
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: "next",
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}