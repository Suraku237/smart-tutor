import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartproject/screens/upload_lesson.dart';
import 'login_screen.dart';

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

  // Load the name we saved during the admin override login
  Future<void> _loadAdminData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('userName') ?? "Admin";
    });
  }

  // Logout function
  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears login session
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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

          // Dashboard Grid
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildAdminCard(
                  context, 
                  "Upload Lesson", 
                  Icons.cloud_upload_outlined, 
                  Colors.blue, 
                  () {
                    // Navigate to the Upload Lesson Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadLessonScreen()),
                    );
                  },
                ),
                _buildAdminCard(context, "Manage Users", Icons.people_alt_outlined, Colors.orange, () {
                  // TODO: Add User Management Logic
                }),
                _buildAdminCard(context, "Lesson Reports", Icons.bar_chart_rounded, Colors.green, () {
                  // TODO: Add Reports Logic
                }),
                _buildAdminCard(context, "Settings", Icons.settings_applications_outlined, Colors.redAccent, () {
                  // TODO: Add Settings Logic
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}