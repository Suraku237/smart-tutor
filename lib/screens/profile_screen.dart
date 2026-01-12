import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../theme_provider.dart';
import 'sentiment_screen.dart';
import 'login_screen.dart';
import 'about_us_screen.dart';
import 'database_helper.dart'; // Ensure this helper exists as we created earlier

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "Loading...";
  String email = "Loading...";
  File? _imageFile; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // UPDATED: Load user data from SharedPreferences and Image from Local Database
  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // 1. Get Text Data
    String name = prefs.getString('userName') ?? "User";
    String userEmail = prefs.getString('userEmail') ?? "No Email Found";

    // 2. Get Image Path from Local SQLite Database
    String? localPath = await LocalDatabaseHelper.instance.getImagePath();
    
    if (mounted) {
      setState(() {
        fullName = name;
        email = userEmail;
        if (localPath != null) {
          _imageFile = File(localPath);
        }
      });
    }
  }

  // UPDATED: Logic to pick, copy to permanent storage, and save to SQLite
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // 1. Get the app's internal permanent directory
      final directory = await getApplicationDocumentsDirectory();
      
      // 2. Create a unique name for the file to avoid cache issues
      final String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.png";
      final String savedPath = '${directory.path}/$fileName';

      // 3. Physically copy the file from temporary to permanent storage
      final File localImage = await File(pickedFile.path).copy(savedPath);

      // 4. Save the new path into the Local SQLite Database
      await LocalDatabaseHelper.instance.saveImagePath(savedPath);

      setState(() {
        _imageFile = localImage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated locally")),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Note: We usually keep the local profile pic even after logout 
    // unless you want to clear the database too.
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PROFILE PICTURE SECTION
            Stack(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: isDark ? Colors.deepPurple.withOpacity(0.3) : Colors.deepPurple.shade100,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.person, size: 80, color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.black : Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // SETTINGS SECTION
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: isDark ? Icons.dark_mode : Icons.wb_sunny_outlined,
                    color: Colors.orange,
                    title: isDark ? "Dark Mode" : "Light Mode",
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                      activeColor: Colors.deepPurpleAccent,
                    ),
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade300),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.info_outline,
                    color: Colors.blue,
                    title: "About Us",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade300),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.feedback_outlined,
                    color: Colors.redAccent,
                    title: "Community Chat", // Updated label
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SentimentScreen()));
                    },
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade300),
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.logout,
                    color: Colors.red,
                    title: "Logout",
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios, size: 18, color: isDark ? Colors.white54 : Colors.grey) : null),
    );
  }
}