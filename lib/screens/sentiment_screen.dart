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
  final ScrollController _scrollController = ScrollController(); // Added for auto-scroll
  bool isLoading = false;
  List<Map<String, String>> qaHistory = [];
  String? userEmail;

  // Change this to your PC's IP (e.g., 192.168.1.5) if testing locally
  // or use 10.0.2.2 for Android Emulator
  final String apiUrl = "http://109.199.120.38:8001"; 

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages();
  }

  Future<void> _loadUserAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail');
    });

    if (userEmail != null) {
      await fetchChatHistory();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> fetchChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/get_messages/$userEmail"),
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
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    }
  }

  Future<void> askQuestion() async {
    String question = _controller.text.trim();
    if (question.isEmpty || userEmail == null) return;

    // 1. OPTIMISTIC UPDATE: Add message to UI immediately
    final String currentTime = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    final Map<String, String> localMsg = {
      "sender": "user",
      "text": question,
      "time": currentTime,
    };

    setState(() {
      qaHistory.add(localMsg);
      isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    try {
      // 2. BACKEND SYNC
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
        // Refresh to get server-validated timestamps
        fetchChatHistory();
      } else {
        // Handle error: maybe show a "failed" icon next to the message
        debugPrint("Server error: ${response.body}");
      }
    } catch (e) {
      debugPrint("Network Error: $e");
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
            if (isLoading) const LinearProgressIndicator(color: Colors.deepPurple, backgroundColor: Colors.transparent),
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Attach controller
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: qaHistory.length,
                itemBuilder: (context, index) {
                  bool isUser = qaHistory[index]['sender'] == "user";
                  return _buildChatBubble(qaHistory[index], isUser, isDark);
                },
              ),
            ),
            _buildInputArea(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, String> msg, bool isUser, bool isDark) {
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
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg['text']!,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              msg['time']!,
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: isDark ? const Color(0xFF1F2C34) : Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A3942) : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: const InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none
                ),
                onSubmitted: (_) => askQuestion(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: askQuestion,
            child: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 24,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}