import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:io';
import '../theme_provider.dart';

class UploadLessonScreen extends StatefulWidget {
  const UploadLessonScreen({super.key});

  @override
  State<UploadLessonScreen> createState() => _UploadLessonScreenState();
}

const String baseUrl = "http://109.199.120.38:8001";

class _UploadLessonScreenState extends State<UploadLessonScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Mathematics';
  File? _lessonFile;
  File? _quizFile;
  bool _isUploading = false;

  final List<String> _categories = [
    'Mathematics', 'Computer Science', 'Physics', 'Chemistry', 
    'Biology', 'Geography', 'Music', 'Economics', 'English', 'History'
  ];

  Future<void> _pickLessonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => _lessonFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickQuizFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => _quizFile = File(result.files.single.path!));
    }
  }

  Future<void> _upload() async {
    final String title = _titleController.text.trim();

    if (title.isEmpty || _lessonFile == null) {
      _showSnackBar("Please enter a title and select a Lesson PDF", Colors.orange);
      return;
    }

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload_lesson"));
      request.fields['title'] = title;
      request.fields['category'] = _selectedCategory;

      // Add Lesson PDF
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        _lessonFile!.path,
        filename: "$title.pdf", // Simplified to match backend storage logic
      ));

      // Add Quiz PDF (if selected)
      if (_quizFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'quiz_file', 
          _quizFile!.path,
          filename: "quiz_$title.pdf", // Matching the prefix expected by backend
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _showSnackBar("Content Uploaded Successfully!", Colors.green);
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar("Upload Failed: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Upload Lesson & Quiz"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("General Information", isDark),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Lesson Title",
                hintText: "e.g. Algebra Basics",
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Subject Category",
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 30),
            
            _buildSectionTitle("Files", isDark),
            const SizedBox(height: 10),
            _buildFileTile("Lesson PDF (Required)", _lessonFile, _pickLessonFile, isDark, Colors.red, true),
            const SizedBox(height: 15),
            _buildFileTile("Quiz PDF (Optional)", _quizFile, _pickQuizFile, isDark, Colors.orange, false),
            
            const SizedBox(height: 40),

            _isUploading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload_rounded),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _upload,
                    label: const Text("SAVE TO SYSTEM", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildFileTile(String label, File? file, VoidCallback onPick, bool isDark, Color iconColor, bool isRequired) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isRequired && file == null) ? Colors.red.withOpacity(0.3) : (isDark ? Colors.white12 : Colors.grey.shade300)
        ),
      ),
      child: ListTile(
        leading: Icon(file == null ? Icons.picture_as_pdf_outlined : Icons.picture_as_pdf, color: iconColor),
        title: Text(
          file == null ? label : file.path.split(Platform.pathSeparator).last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file != null) 
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => setState(() {
                  if (label.contains("Lesson")) _lessonFile = null; else _quizFile = null;
                }),
              ),
            TextButton(
              onPressed: onPick,
              child: Text(file == null ? "Select" : "Change"),
            ),
          ],
        ),
      ),
    );
  }
}