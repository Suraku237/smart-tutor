import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:dio/dio.dart'; // Ensure dio is in pubspec.yaml
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
  
  // List to store subjects fetched from VPS
  List<Map<String, dynamic>> _allSubjects = [];
  List<Map<String, dynamic>> _filteredSubjects = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchSubjectsFromVPS();
  }

  // Logic to fetch unique categories from your VPS database
  Future<void> _fetchSubjectsFromVPS() async {
    try {
      final response = await Dio().get("http://109.199.120.38:8001/get_lessons");
      
      if (response.data['success']) {
        List lessons = response.data['lessons'];
        
        // Extract unique categories using a Set
        Set<String> categories = lessons.map((l) => l['category'].toString()).toSet();
        
        // Map categories to the format expected by your UI
        List<Map<String, dynamic>> fetchedSubjects = categories.map((cat) {
          return {
            "id": cat,
            "name": cat.toUpperCase(),
            "icon": _getIconForCategory(cat), // Helper to pick an emoji
          };
        }).toList();

        setState(() {
          _allSubjects = fetchedSubjects;
          _filteredSubjects = fetchedSubjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
      setState(() => _isLoading = false);
    }
  }

  // Simple helper to assign icons based on category name
  String _getIconForCategory(String category) {
    String cat = category.toLowerCase();
    if (cat.contains("math")) return "📐";
    if (cat.contains("physics")) return "⚛️";
    if (cat.contains("chem")) return "🧪";
    if (cat.contains("bio")) return "🧬";
    if (cat.contains("eng")) return "📖";
    return "📚"; // Default icon
  }

  void filterSubjects(String query) {
    setState(() {
      _filteredSubjects = _allSubjects
          .where((subject) =>
              subject["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SentimentScreen()))
          .then((_) => setState(() => _selectedIndex = 0)); 
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))
          .then((_) => setState(() => _selectedIndex = 0)); 
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
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSubjectsFromVPS, // Pull to refresh subjects
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubjects.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredSubjects.length,
                      itemBuilder: (context, index) {
                        return _buildSubjectPaperTile(_filteredSubjects[index], isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  // Extracted Header for cleaner code
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hello, Learner!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Select a subject to view available materials", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          _buildSearchBox(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBox(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: filterSubjects,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: "Search subjects...",
          hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurpleAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No subjects found. Try refreshing."));
  }

  Widget _buildSubjectPaperTile(Map<String, dynamic> subject, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(subjectId: subject["id"])));
        },
        leading: Container(
          width: 55, height: 55,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(subject["icon"], style: const TextStyle(fontSize: 28))),
        ),
        title: Text(subject["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
        subtitle: const Text("View all papers & notes", style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.deepPurpleAccent),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      selectedItemColor: Colors.deepPurpleAccent,
      unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Feedback'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}