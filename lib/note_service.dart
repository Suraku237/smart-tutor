import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteService {
  // IMPORTANT: Replace this with your own Raw Gist URL!
  final String gistUrl = "https://gist.githubusercontent.com/Suraku237/32646eb98ba631995c01d3ae8dfdb910/raw/1dfc10b787f9834480e45702adee72fd6e416a3e/notes_database.json";

  Future<List<dynamic>> fetchNotesBySubject(String subjectId) async {
    try {
      final response = await http.get(Uri.parse(gistUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List subjects = data['subjects'];
        
        // This searches for the subject (e.g., 'math') in your online JSON
        final subjectData = subjects.firstWhere(
          (s) => s['subjectId'] == subjectId,
          orElse: () => {'notes': []},
        );
        
        return subjectData['notes'];
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Check your internet connection.");
    }
  }
}