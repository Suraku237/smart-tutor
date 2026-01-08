import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class NotePage extends StatefulWidget {
  final String pdfPath;
  final String title;

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
  
  // FIX: Added controller to allow programmatic page jumping
  PDFViewController? _pdfViewController;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Page Indicator
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "${currentPage + 1} / $totalPages",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false, 
            autoSpacing: true,
            pageFling: true,
            // Automatically inverts colors if the app is in Dark Mode
            nightMode: isDark, 
            backgroundColor: isDark ? Colors.black : Colors.grey.shade200,
            onRender: (pages) {
              setState(() {
                totalPages = pages!;
                isReady = true;
              });
            },
            onViewCreated: (PDFViewController controller) {
              setState(() {
                _pdfViewController = controller;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                currentPage = page!;
              });
            },
            onError: (error) {
              debugPrint("PDF Error: ${error.toString()}");
            },
          ),
          
          if (!isReady)
            const Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
        ],
      ),
      
      // Fixed Navigation Buttons
      floatingActionButton: isReady ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "prev",
            backgroundColor: Colors.deepPurple.withOpacity(0.8),
            child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            onPressed: () {
              if (currentPage > 0) {
                _pdfViewController?.setPage(currentPage - 1);
              }
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: "next",
            backgroundColor: Colors.deepPurple.withOpacity(0.8),
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: () {
              if (currentPage < totalPages - 1) {
                _pdfViewController?.setPage(currentPage + 1);
              }
            },
          ),
        ],
      ) : null,
    );
  }
}