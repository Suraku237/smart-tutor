import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. ADD THIS IMPORT
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartproject/screens/upload_lesson.dart';
import '../theme_provider.dart'; // 2. IMPORT YOUR THEME PROVIDER
import 'login_screen.dart';
import 'delete.dart';
import 'sentiment_screen.dart';
import 'profile_screen.dart';

class HomeAdminsScreen extends StatefulWidget {
  const HomeAdminsScreen({super.key});

  @override
  State<HomeAdminsScreen> createState() => _HomeAdminsScreenState();
}

class _HomeAdminsScreenState extends State<HomeAdminsScreen> {
  String adminName = "Admin";

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('userName') ?? "Admin";
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. LISTEN TO THE THEME
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      // 4. DYNAMIC BACKGROUND COLOR
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
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
                Text("Welcome back,", style: TextStyle(color: Colors.deepPurple.shade100, fontSize: 16)),
                Text(adminName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("What would you like to manage today?", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildAdminCard(
                  context, 
                  isDark,
                  "Upload Lesson", 
                  Icons.cloud_upload_outlined, 
                  Colors.blue, 
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadLessonScreen()));
                  },
                ),
                _buildAdminCard(
                  context, 
                  isDark,
                  "Delete Lessons",
                   Icons.delete_forever, 
                   Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteLessonScreen()));
                }),

                _buildAdminCard(
                  context, 
                  isDark,
                  "Student feedback", 
                  Icons.insert_emoticon_rounded, 
                  Colors.green, 
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SentimentScreen()));
                }),

                _buildAdminCard(
                  context, 
                  isDark,
                  "Settings", 
                  Icons.settings_applications_outlined, 
                  Colors.redAccent, 
                  () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. UPDATED CARD WIDGET TO SUPPORT DARK MODE
  Widget _buildAdminCard(BuildContext context, bool isDark, String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      // Dynamic card background
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: isDark ? 0 : 2,
      // Add a subtle border in dark mode for better visibility
      shape: isDark ? RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(20),
      ) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  // Dynamic text color
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}