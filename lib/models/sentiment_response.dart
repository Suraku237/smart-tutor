// lib/models/sentiment_response.dart
class SentimentResponse {
  final String sentiment; // positive, negative, neutral
  final String message;
  final double confidence;
  final List<String> suggestions;

  SentimentResponse({
    required this.sentiment,
    required this.message,
    required this.confidence,
    required this.suggestions,
  });

  factory SentimentResponse.fromJson(Map<String, dynamic> json) {
    return SentimentResponse(
      sentiment: json['sentiment'] ?? 'neutral',
      message: json['message'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}