import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this
import 'package:http/http.dart' as http; // Add this
import 'dart:convert'; // Add this
import '../theme_provider.dart';

class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});

  @override
  State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  List<Map<String, String>> qaHistory = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages(); // Load data when screen opens
  }

  // 1. Load the user's email and fetch their specific history from the API
  Future<void> _loadUserAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail'); // Make sure you saved this during login
    });

    if (userEmail != null) {
      fetchChatHistory();
    }
  }

  // 2. Fetch messages from the GET endpoint
  Future<void> fetchChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse("http://109.199.120.38:8001/get_messages/$userEmail"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            qaHistory = List<Map<String, String>>.from(
              data['history'].map((item) => {
                "sender": item['sender_type'].toString(),
                "text": item['message_text'].toString(),
                "time": item['timestamp'].toString(),
              }),
            );
          });
        }
      }
    } catch (e) {
      print("Error fetching history: $e");
    }
  }

  // 3. Send message to the POST endpoint
  Future<void> askQuestion() async {
    String question = _controller.text.trim();
    if (question.isEmpty || userEmail == null) return;

    setState(() => isLoading = true);
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse("http://109.199.120.38:8001/send_message"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": userEmail,
          "message": question,
          "sender": "user",
        }),
      );

      if (response.statusCode == 200) {
        // Refresh history to show the new message
        fetchChatHistory();
      }
    } catch (e) {
      print("Error sending message: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Chat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1F2C34) : Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B141A) : const Color(0xFFE5DDD5),
        ),
        child: Column(
          children: [
            if (isLoading) const LinearProgressIndicator(color: Colors.deepPurple),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: qaHistory.length,
                itemBuilder: (context, index) {
                  bool isUser = qaHistory[index]['sender'] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: isUser 
                            ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFDCF8C6))
                            : (isDark ? const Color(0xFF1F2C34) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            qaHistory[index]['text']!,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16),
                          ),
                          Text(
                            qaHistory[index]['time']!,
                            style: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // ... (Your Bottom Input Field remains the same, just ensure it calls askQuestion)
            _buildInputArea(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2C34) : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: const InputDecoration(hintText: "Type a message", border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: askQuestion,
            child: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}