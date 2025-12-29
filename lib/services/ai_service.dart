import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // Replace this with your actual API Key from Google AI Studio
  static const String _apiKey = 'AIzaSyAnPXbKeTpcCs959gnYYngfaPvl1Bl5k50';

  static Future<String> generateLessonContent(String subjectName) async {
    try {
      // 1. Initialize the model (Gemini 1.5 Flash is fast and cheap/free)
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
      );

      // 2. Craft the prompt
      final prompt = "Act as an expert tutor. Create a comprehensive, engaging, and easy-to-understand lesson about $subjectName for a high school student. Use clear headings, bullet points, and include a 'Fun Fact' at the end.";

      // 3. Generate the response
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? "No content generated.";
    } catch (e) {
      return "Error: Could not connect to AI. Check your internet or API key. ($e)";
    }
  }
}