import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this
import '../theme_provider.dart';        // Ensure this path is correct

class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});

  @override
  State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String? aiMessage;

  late AnimationController animController;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeAnim = CurvedAnimation(
      parent: animController,
      curve: Curves.easeIn,
    );
  }

  void analyzeSentiment() {
    String userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      isLoading = true;
      aiMessage = null;
    });

    _controller.clear();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        if (userText.contains("tired") || userText.contains("stress")) {
          aiMessage = "I’m sorry you’re feeling stressed 😔. "
              "Take a short break, breathe, and we will continue at your pace.";
        } else if (userText.contains("happy") || userText.contains("good")) {
          aiMessage = "That's great to hear! 😊 Let's keep the momentum going!";
        } else if (userText.contains("confused") || userText.contains("don't understand")) {
          aiMessage = "No worries! 🤝 I will explain the topic again in a simpler way.";
        } else {
          aiMessage = "Thank you for sharing how you feel 💬 "
              "I’m here to support your learning journey.";
        }
        animController.forward(from: 0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      // 2. Set dynamic background color
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Sentiment Support", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CHAT BUBBLE — AI RESPONSE
            if (aiMessage != null)
              FadeTransition(
                opacity: fadeAnim,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    // 3. Dynamic Bubble Color
                    color: isDark ? Colors.deepPurple.shade900.withOpacity(0.4) : Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? Border.all(color: Colors.deepPurple.shade700, width: 1) : null,
                  ),
                  child: Text(
                    aiMessage!,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      // 4. Dynamic Text Color
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),

            // LOADING INDICATOR
            if (isLoading)
              Row(
                children: [
                  const CircularProgressIndicator(color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Text(
                    "SmartTutor is analyzing...",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),

            const Spacer(),

            // INPUT FIELD CONTAINER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // 5. Dynamic Input Box Color
                color: isDark ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    color: isDark ? Colors.black54 : Colors.black12,
                  )
                ],
                borderRadius: BorderRadius.circular(14),
                border: isDark ? Border.all(color: Colors.grey.shade800) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Tell SmartTutor how you feel...",
                        hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: analyzeSentiment,
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