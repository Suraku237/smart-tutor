// lib/models/lesson.dart
class Lesson {
  final String id;
  final String title;
  final String category;
  final String? uploadDate; // Optional: helps show when the PDF was added

  Lesson({
    required this.id,
    required this.title,
    required this.category,
    this.uploadDate,
  });

  // Factory method to convert JSON from your VPS into a Lesson object
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Lesson',
      category: json['category'] ?? 'General',
      uploadDate: json['upload_date'],
    );
  }

  // Helper to get the full PDF URL for this specific lesson
  String get pdfUrl {
    final encodedCat = Uri.encodeComponent(category);
    final encodedTitle = Uri.encodeComponent(title);
    return "http://109.199.120.38:8001/assert%20lessons/$encodedCat/$encodedTitle.pdf";
  }
}