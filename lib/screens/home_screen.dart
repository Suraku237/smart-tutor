// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/dummy_data.dart';
import '../widgets/lesson_card.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> subjects = DummyData.subjects;
  List<Map<String, dynamic>> filteredSubjects = [];

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          // SEARCH BAR
          TextField(
            controller: _searchController,
            onChanged: filterSubjects,
            decoration: InputDecoration(
              hintText: "Search for a subject...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // SUBJECT LIST TITLE
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Available Subjects",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // SUBJECT GRID
          Expanded(
            child: GridView.builder(
              itemCount: filteredSubjects.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                var subject = filteredSubjects[index];

                return LessonCard(
                  emoji: subject["icon"],
                  title: subject["name"],
                  onTapLesson: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(subjectId: subject["id"]),
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
    );
  }
}