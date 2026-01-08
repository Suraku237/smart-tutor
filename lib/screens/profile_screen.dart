import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';
import 'sentiment_screen.dart';
import 'login_screen.dart';
import 'about_us_screen.dart'; // Import your new screen here

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

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('userName') ?? "User";
      email = prefs.getString('userEmail') ?? "No Email Found";
    });
  }

  Future<void> _handleLogout() async {
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ?Colors.deepPurple : Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: isDark ? Colors.deepPurple.withOpacity(0.2) : Colors.deepPurple.shade100,
              child: Icon(Icons.person, size: 70, color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple),
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
                  
                  // --- RESTORED NAVIGATION ---
                  _buildSettingsTile(
                    isDark: isDark,
                    icon: Icons.info_outline,
                    color: Colors.blue,
                    title: "About Us",
                    onTap: () {
                      // Pushes the full AboutUsScreen onto the navigation stack
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
                    title: "Feedback",
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