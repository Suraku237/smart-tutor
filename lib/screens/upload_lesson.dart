import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class UploadLessonScreen extends StatefulWidget {
  const UploadLessonScreen({super.key});

  @override
  State<UploadLessonScreen> createState() => _UploadLessonScreenState();
}

const String baseUrl = "http://109.199.120.38:8001"; 

class _UploadLessonScreenState extends State<UploadLessonScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Mathematics'; // Default value
  File? _selectedFile;
  bool _isUploading = false;

  // Available categories for the dropdown
  final List<String> _categories = ['Mathematics', 'Computer Science','Physics','Chemistry', 'Biology', 'Geography', 'Music', 'Economics', 'English', 'History'];

  

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
      // FIX 1: Use 'url' (lowercase) which is your defined Uri object
      var request = http.MultipartRequest('POST', url); 
      
      // Fields matching your FastAPI Form params
      request.fields['title'] = _titleController.text.trim();
      request.fields['category'] = _selectedCategory;

      // Attach file
      // FIX 2: Ensure the field name 'file' matches your FastAPI parameter
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        _selectedFile!.path,
        filename: "${_titleController.text.trim()}.pdf", 
      ));

      // Send the request
      var streamedResponse = await request.send();
      
      // Convert streamedResponse to a standard response to read the body if needed
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload Successful!")),
        );
        if (mounted) Navigator.pop(context); 
      } else {
        debugPrint("Server Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Error during upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred during upload")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Lesson")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Lesson Title",
                border: OutlineInputBorder(),
                hintText: "Enter the name of the lesson",
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Select Category",
                border: OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            ListTile(
              tileColor: Colors.grey[200],
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(_selectedFile == null 
                  ? "No file selected" 
                  : _selectedFile!.path.split('/').last),
              trailing: ElevatedButton(
                onPressed: _pickFile,
                child: const Text("Pick PDF"),
              ),
            ),
            const SizedBox(height: 30),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _upload,
                    child: const Text("UPLOAD TO DATABASE"),
                  ),
          ],
        ),
      ),
    );
  }
}