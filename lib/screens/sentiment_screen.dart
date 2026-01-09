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
  String? userEmail; // Your email (to align your messages to the right)

  final String apiUrl = "http://109.199.120.38:8001"; 

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages();
  }

  Future<void> _loadUserAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? "Anonymous";
    });
    // Fetch GLOBAL history
    await fetchCommunityChatHistory();
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

  // --- UPDATED: Fetch ALL messages from the new endpoint ---
  Future<void> fetchCommunityChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/get_community_messages"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            qaHistory = List<Map<String, String>>.from(
              data['history'].map((item) => {
                "sender_email": item['user_email'].toString(),
                "sender_type": item['sender_type'].toString(),
                "text": item['message_text'].toString(),
                "time": item['timestamp'].toString(),
              }),
            );
            // Reverse history because backend sends DESC (newest first) 
            // but Chat UI usually needs oldest first at top
            qaHistory = qaHistory.reversed.toList();
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Community Fetch Error: $e");
    }
  }

  Future<void> askQuestion() async {
    String question = _controller.text.trim();
    if (question.isEmpty || userEmail == null) return;

    setState(() => isLoading = true);
    
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
        _controller.clear();
        await fetchCommunityChatHistory(); // Refresh the feed for everyone
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error. Could not send.")),
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
        title: const Text("Community Chat"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchCommunityChatHistory),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0B141A) : const Color(0xFFF0F2F5),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: qaHistory.length,
                itemBuilder: (context, index) {
                  final msg = qaHistory[index];
                  // Align right if the message was sent by CURRENT user
                  bool isMe = msg['sender_email'] == userEmail;
                  return _chatBubble(msg, isMe, isDark);
                },
              ),
            ),
            if (isLoading) const LinearProgressIndicator(color: Colors.deepPurple),
            _inputArea(isDark),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(Map<String, String> msg, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Show email of the sender (Small text above bubble)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              isMe ? "You" : msg['sender_email']!,
              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[700]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? Colors.deepPurple : (isDark ? Colors.grey[800] : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isMe ? 15 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg['text']!,
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg['time']!,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: isDark ? Colors.black : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Message the community...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: askQuestion,
            ),
          ),
        ],
      ),
    );
  }
}