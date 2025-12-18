// lib/screens/home_screen.dart - Updated
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
import '../models/subject_model.dart';
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

  List<Subject> subjects = [];
  List<Subject> filteredSubjects = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final response = await ApiService.getSubjects();

    setState(() {
      isLoading = false;
      
      if (response.success && response.data != null) {
        subjects = response.data!;
        filteredSubjects = subjects;
      } else {
        errorMessage = response.message;
        
        // Show error dialog if needed
        if (response.message.contains('Connection error') || 
            response.message.contains('Failed')) {
          _showErrorDialog(response.message);
        }
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadSubjects(); // Retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // SEARCH FILTER
  void filterSubjects(String query) {
    setState(() {
      filteredSubjects = subjects
          .where((subject) =>
              subject.name.toLowerCase().contains(query.toLowerCase()))
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

          // LOADING INDICATOR
          if (isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(
                      color: Colors.deepPurple,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                    const Text('Loading subjects...'),
                  ],
                ),
              ),
            ),

          // ERROR MESSAGE
          if (!isLoading && errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadSubjects,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // SUBJECTS LIST
          if (!isLoading && errorMessage.isEmpty)
            Column(
              children: [
                // SUBJECT LIST TITLE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Available Subjects",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                // SUBJECT COUNT
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${filteredSubjects.length} subjects found",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // SUBJECT GRID
                Expanded(
                  child: filteredSubjects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No subjects found',
                                style: TextStyle(fontSize: 16),
                              ),
                              if (_searchController.text.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    filterSubjects('');
                                  },
                                  child: const Text('Clear search'),
                                ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          itemCount: filteredSubjects.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final subject = filteredSubjects[index];

                            return LessonCard(
                              emoji: subject.icon,
                              title: subject.name,
                              onTapLesson: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LessonScreen(subjectId: subject.id),
                                  ),
                                );
                              },
                              onTapQuiz: () {
                                // For now, use subject ID as lesson ID
                                // You might want to get the first lesson ID from API
                                String lessonId = "${subject.id}_lesson1";

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      subjectId: subject.id,
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
        ],
      ),
    );
  }
}