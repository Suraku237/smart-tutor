// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/dummy_data.dart';
import '../widgets/lesson_card.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'profile_screen.dart';      // Added Import
import 'sentiment_screen.dart';    // Added Import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> subjects = DummyData.subjects;
  List<Map<String, dynamic>> filteredSubjects = [];
  
  // 1. TRACK THE CURRENT TAB
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    filteredSubjects = subjects;
  }

  void filterSubjects(String query) {
    setState(() {
      filteredSubjects = subjects
          .where((subject) =>
              subject["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // 2. NAVIGATION LOGIC FOR THE BAR
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Navigate to Feedback (Sentiment Screen)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SentimentScreen()),
      ).then((_) => setState(() => _selectedIndex = 0)); // Reset to home icon on return
    } else if (index == 2) {
      // Navigate to Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 0)); // Reset to home icon on return
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Tutor"),
        backgroundColor: Colors.deepPurple,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // SEARCH BAR
            TextField(
              controller: _searchController,
              onChanged: filterSubjects,
              decoration: InputDecoration(
                hintText: "Search subjects...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SUBJECT GRID
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredSubjects.length,
                itemBuilder: (context, index) {
                  var subject = filteredSubjects[index];

                  return LessonCard(
                    emoji: subject["icon"],
                    title: subject["name"],
                    onTapLesson: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LessonScreen(subjectId: subject["id"]),
                        ),
                      );
                    },
                    onTapQuiz: () {
                      String lessonId = "${subject["id"]}1";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            subjectId: subject["id"],
                            lessonId: lessonId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // 3. ADD THE BOTTOM NAVIGATION BAR HERE
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Keeps labels visible
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}