// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../services/dummy_data.dart';
import '../theme_provider.dart';
import 'lesson_screen.dart'; 
import 'profile_screen.dart';
import 'sentiment_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> subjects = DummyData.subjects;
  List<Map<String, dynamic>> filteredSubjects = [];
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

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SentimentScreen()),
      ).then((_) => setState(() => _selectedIndex = 0)); 
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 0)); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Smart Tutor", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDark ?Colors.deepPurple : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: BoxDecoration(
              color: isDark ?Colors.deepPurple : Colors.deepPurple,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello, Learner!",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Select a subject to view available materials",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black54 : Colors.black12, 
                        blurRadius: 10
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: filterSubjects,
                    // Fix: Input text color for Dark Mode
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Search subjects...",
                      hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SUBJECT LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredSubjects.length,
              itemBuilder: (context, index) {
                var subject = filteredSubjects[index];
                return _buildSubjectPaperTile(subject, isDark);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        selectedItemColor: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSubjectPaperTile(Map<String, dynamic> subject, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonScreen(
                subjectId: subject["id"],
              ),
            ),
          );
        },
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: isDark ? Colors.deepPurple.withOpacity(0.2) : Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              subject["icon"] ?? "📚", 
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Text(
          subject["name"],
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black, // Title color logic
          ),
        ),
        subtitle: Text(
          "View all papers & notes", 
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54, // Subtitle color logic
          ),
        ),
        trailing: Icon(
          Icons.chevron_right, 
          color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple
        ),
      ),
    );
  }
}