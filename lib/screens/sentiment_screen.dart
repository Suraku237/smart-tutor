import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  
  // Storage for chat messages
  List<Map<String, String>> qaHistory = [];

  late AnimationController animController;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fadeAnim = CurvedAnimation(parent: animController, curve: Curves.easeIn);
  }

  void askQuestion() {
    String question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      isLoading = true;
      qaHistory.add({
        "sender": "user", 
        "text": question, 
        "time": "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"
      });
    });

    _controller.clear();

    // Simulated Admin Response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        qaHistory.add({
          "sender": "admin", 
          "text": "Message received. An administrator will review your request shortly.",
          "time": "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"
        });
        animController.forward(from: 0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sentemet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1F2C34) : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        // WhatsApp Wallpaper Background
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B141A) : const Color(0xFFE5DDD5),
        ),
        child: Column(
          children: [
            // The BarChart container has been removed from here to clean up the UI
            
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
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            qaHistory[index]['text']!,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87, 
                              fontSize: 16
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            qaHistory[index]['time']!,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black45, 
                              fontSize: 11
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // WhatsApp Style Bottom Input
            Padding(
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
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: const InputDecoration(
                                hintText: "Type a message",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
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
            ),
          ],
        ),
      ),
    );
  }
}