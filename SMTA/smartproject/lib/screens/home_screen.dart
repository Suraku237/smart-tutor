import 'package:flutter/material.dart';
import 'lessons_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  // SUBJECT LIST
  List<Map<String, dynamic>> subjects = [
    {"icon": Icons.calculate, "title": "Mathematics"},
    {"icon": Icons.science, "title": "Physics"},
    {"icon": Icons.biotech, "title": "Biology"},
    {"icon": Icons.book, "title": "English"},
    {"icon": Icons.computer, "title": "Computer Science"},
    {"icon": Icons.menu_book, "title": "Chemistry"},
  ];

  // FILTERED LIST (Starts with all subjects)
  List<Map<String, dynamic>> filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    filteredSubjects = subjects; // show all at first

    _searchController.addListener(() {
      filterSubjects();
    });
  }

  void filterSubjects() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      filteredSubjects = subjects
          .where((subj) =>
              subj["title"].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "SmartTutor",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // WORKING SEARCH BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search subjects...",
                  icon: Icon(Icons.search, color: Colors.deepPurple),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Subjects",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 15),

            // GRID USING THE FILTERED LIST
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: filteredSubjects.map((subject) {
                  return subjectCard(
                    subject["icon"],
                    subject["title"],
                    context,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  // CARD WIDGET
  Widget subjectCard(IconData icon, String title, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonsScreen(subject: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
