import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class QuizViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const QuizViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}