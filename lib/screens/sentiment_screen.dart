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
  // --- Controllers & Local State ---
  final TextEditingController _controller = TextEditingController(); // For the message input field
  final ScrollController _scrollController = ScrollController();    // To control chat scrolling
  bool isLoading = false;                                           // Shows a progress bar during API calls
  List<Map<String, String>> qaHistory = [];                         // Stores the chat messages locally
  String? userEmail;                                                // Current user's email for message alignment

  // The backend API URL pointing to your Contabo VPS
  final String apiUrl = "http://109.199.120.38:8001"; 

  @override
  void initState() {
    super.initState();
    // Start by loading the user identity and previous chat history
    _loadUserAndMessages();
  }

  /// Loads the logged-in user's email from disk and fetches global history
  Future<void> _loadUserAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // If no email found, default to 'Anonymous'
      userEmail = prefs.getString('userEmail') ?? "Anonymous";
    });
    // Call the global fetch function
    await fetchCommunityChatHistory();   
  }

  /// Utility function to force the list to scroll to the very bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// GET: Fetches all community messages from the VPS backend
  Future<void> fetchCommunityChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/get_community_messages"),
      ).timeout(const Duration(seconds: 10)); // Timeout prevents app freezing on slow networks

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            // Map the raw JSON list into our local List<Map<String, String>>
            qaHistory = List<Map<String, String>>.from(
              data['history'].map((item) => {
                "sender_email": item['user_email'].toString(),
                "sender_type": item['sender_type'].toString(),
                "text": item['message_text'].toString(),
                "time": item['timestamp'].toString(),
              }),
            );
          });
          // After loading messages, scroll down to see the latest one
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Community Fetch Error: $e");
    }
  }

  /// POST: Sends a new message to the backend
  Future<void> askQuestion() async {
    String question = _controller.text.trim();
    // Validate input: don't send empty messages or if user is unknown
    if (question.isEmpty || userEmail == null) return;

    setState(() => isLoading = true); // Start progress indicator
    
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/send_message"),// Endpoint for sending messages
        headers: {"Content-Type": "application/json"},// Set JSON headers
        body: json.encode({
          "email": userEmail,
          "message": question,
          "sender": "user",
        }),// Encode the body as JSON
      );

      if (response.statusCode == 200) {
        _controller.clear(); // Clear input box on success
        // Immediately refresh the history so the new message appears
        await fetchCommunityChatHistory(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error. Could not send.")),
      );
    } finally {
      setState(() => isLoading = false); // Stop progress indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the ThemeProvider for Dark/Light mode changes
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Chat"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Manual refresh button in the top bar
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchCommunityChatHistory),
        ],
      ),
      body: Container(
        // WhatsApp-style background colors
        color: isDark ? const Color(0xFF0B141A) : const Color(0xFFF0F2F5),
        child: Column(
          children: [
            // --- Chat Message Area ---
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: qaHistory.length,
                itemBuilder: (context, index) {
                  final msg = qaHistory[index];
                  // If sender matches current user, bubble goes to the RIGHT
                  bool isMe = msg['sender_email'] == userEmail;
                  return _chatBubble(msg, isMe, isDark);
                },
              ),
            ),
            // Shows loading bar at the top of input area when sending
            if (isLoading) const LinearProgressIndicator(color: Colors.deepPurple),
            // --- Bottom Input Area ---
            _inputArea(isDark),
          ],
        ),
      ),
    );
  }

  /// Builds a single chat bubble
  Widget _chatBubble(Map<String, String> msg, bool isMe, bool isDark) {
    return Align(
      // Alignment logic: Me = Right, Others = Left
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Header: Show "You" or the sender's email address
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              isMe ? "You" : msg['sender_email']!,
              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[700]),
            ),
          ),
          // The actual message container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              // Colors: Purple for me, Grey/White for others
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
                  msg['text']!, // The message content
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg['time']!, // The timestamp from the database
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

  /// Builds the bottom text input field and send button
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
                hintStyle: const TextStyle(color: Colors.grey),
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
          // The Send Button
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