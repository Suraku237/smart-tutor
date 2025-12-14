import 'package:flutter/material.dart';

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

    // Simulate “AI Typing”
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;

        /// SIMULATED EMOTIONAL FEEDBACK
        /// LATER YOU WILL REPLACE THIS WITH VPS API RESPONSE
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sentiment Support"),
        backgroundColor: Colors.deepPurple,
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
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    aiMessage!,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

            // LOADING INDICATOR (AI typing…)
            if (isLoading)
              Row(
                children: [
                  const CircularProgressIndicator(color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  const Text(
                    "SmartTutor is analyzing...",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

            const Spacer(),

            // INPUT FIELD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    color: Colors.black12,
                  )
                ],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Tell SmartTutor how you feel...",
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
