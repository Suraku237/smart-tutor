import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this
import '../theme_provider.dart';
import 'sentiment_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load the data we saved during Login
  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('userName') ?? "User";
      email = prefs.getString('userEmail') ?? "No Email Found";
    });
  }

  Future<void> _handleLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear session data
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

    return Scaffold(
      // Background color adapts to light/dark mode
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.shade100,
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
            // --- DYNAMIC PROFILE HEADER ---
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.person, size: 70, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            Text(
              fullName, // Dynamic Name
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              email, // Dynamic Email
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            // --- THE SETTINGS BOX ---
            Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
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
                    icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.wb_sunny_outlined,
                    color: Colors.orange,
                    title: themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                      activeColor: Colors.deepPurple,
                    ),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.share_outlined,
                    color: Colors.blue,
                    title: "Share App",
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.feedback_outlined,
                    color: Colors.redAccent,
                    title: "Feedback",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SentimentScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  // --- LOGOUT TILE ---
                  _buildSettingsTile(
                    icon: Icons.logout,
                    color: Colors.red,
                    title: "Logout",
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // EDIT PROFILE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 24, color: Colors.white),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
    );
  }
}