import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme_provider.dart';

class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});

  @override
  State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  List<Map<String, String>> qaHistory = [];
  String? userEmail;

  final String apiUrl = "http://109.199.120.38:8001"; 

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages();
  }

  // Ensures data is loaded every time the screen is built
  Future<void> _loadUserAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('userEmail');
    
    if (storedEmail != null) {
      setState(() {
        userEmail = storedEmail;
      });
      // Fetch history from VPS immediately
      await fetchChatHistory();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> fetchChatHistory() async {
    if (userEmail == null) return;
    
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/get_messages/$userEmail"),
      ).timeout(const Duration(seconds: 10));

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
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("History Fetch Error: $e");
    }
  }

  Future<void> askQuestion() async {
    String question = _controller.text.trim();
    if (question.isEmpty || userEmail == null) return;

    final String currentTime = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    
    // Add to local list immediately so it stays on screen
    setState(() {
      qaHistory.add({
        "sender": "user",
        "text": question,
        "time": currentTime,
      });
      isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/send_message"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": userEmail,
          "message": question,
          "sender": "user",
        }),
      );

      if (response.statusCode == 200) {
        // Sync with server to get the official DB timestamp
        fetchChatHistory();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error. Message saved locally.")),
      );
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
        title: const Text("Support Chat"),
        backgroundColor: isDark ? Colors.deepPurple : Colors.deepPurple,
        actions: [
          // Refresh button to manually pull messages
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchChatHistory),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0B141A) : const Color(0xFFE5DDD5),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: qaHistory.length,
                itemBuilder: (context, index) {
                  final msg = qaHistory[index];
                  bool isUser = msg['sender'] == "user";
                  return _chatBubble(msg, isUser, isDark);
                },
              ),
            ),
            if (isLoading) const LinearProgressIndicator(),
            _inputArea(isDark),
          ],
        ),
      ),
    );
  }

  // Rest of the UI helper methods (_chatBubble and _inputArea) remain the same...
  Widget _chatBubble(Map<String, String> msg, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple[400] : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg['text']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(msg['time']!, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _inputArea(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type here...",
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: askQuestion),
        ],
      ),
    );
  }
}