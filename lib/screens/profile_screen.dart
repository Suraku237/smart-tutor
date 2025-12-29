import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Add this
import '../theme_provider.dart';        // 2. Add your provider file path
import 'sentiment_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Listen to the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), 
        child: Column(
          children: [
            // PROFILE HEADER
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.person, size: 70, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            const Text("John Doe", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // THE SETTINGS BOX
            Container(
              decoration: BoxDecoration(
                // 4. Box color adapts to Dark/Light mode
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
                  // --- FUNCTIONAL THEME SWITCH ---
                  _buildSettingsTile(
                    icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.wb_sunny_outlined,
                    color: Colors.orange,
                    title: themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
                    trailing: Switch(
                      value: themeProvider.isDarkMode, 
                      onChanged: (value) {
                        themeProvider.toggleTheme(value); // 5. Toggle logic
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
                    icon: Icons.star_outline,
                    color: Colors.amber,
                    title: "Rate Us",
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    color: Colors.teal,
                    title: "About Us",
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), 
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