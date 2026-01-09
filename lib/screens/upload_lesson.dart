import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Ensure Provider is imported
import 'dart:io';
import '../theme_provider.dart'; // Import your ThemeProvider

class UploadLessonScreen extends StatefulWidget {
  const UploadLessonScreen({super.key});

  @override
  State<UploadLessonScreen> createState() => _UploadLessonScreenState();
}

const String baseUrl = "http://109.199.120.38:8001";

class _UploadLessonScreenState extends State<UploadLessonScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Mathematics';
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _categories = [
    'Mathematics', 'Computer Science', 'Physics', 'Chemistry', 
    'Biology', 'Geography', 'Music', 'Economics', 'English', 'History'
  ];

  final url = Uri.parse("$baseUrl/upload_lesson");

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title and select a PDF")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['title'] = _titleController.text.trim();
      request.fields['category'] = _selectedCategory;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedFile!.path,
        filename: "${_titleController.text.trim()}.pdf",
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload Successful!")),
        );
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred during upload")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      // 2. Dynamic background color
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Upload Lesson"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView( // Added scroll view to prevent overflow
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Input
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Lesson Title",
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Enter the name of the lesson",
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown Input
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Select Category",
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),

            // File Selection Tile
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(
                  _selectedFile == null
                      ? "No file selected"
                      : _selectedFile!.path.split('/').last,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                trailing: TextButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Pick PDF"),
                  style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Upload Button
            _isUploading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _upload,
                    child: const Text(
                      "UPLOAD TO DATABASE",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}