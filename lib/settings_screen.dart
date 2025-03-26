import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Import halaman login

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true; // Status toggle switch

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup popup
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: _logout, // Panggil fungsi logout
              child: const Text("Ya", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Logout dari Firebase
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Arahkan ke Login
            (route) => false, // Hapus semua halaman sebelumnya
      );
    } catch (e) {
      debugPrint("Logout gagal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna background
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        elevation: 0, // Hilangkan shadow
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Bagas",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Active",
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Account Settings Section
            const Text(
              "Account Settings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // List Menu
            _buildSettingsOption("Edit Profile", Icons.arrow_forward_ios),
            _buildSettingsOption("Change Password", Icons.arrow_forward_ios),
            _buildSettingsOption("Add a Payment Method", Icons.add),

            // Push Notification Toggle
            ListTile(
              title: const Text("Push Notifications"),
              trailing: Switch(
                value: _isNotificationEnabled,
                activeColor: Colors.pink, // Warna sesuai gambar
                onChanged: (value) {
                  setState(() {
                    _isNotificationEnabled = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // Warna sesuai gambar
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                ),
                onPressed: _confirmLogout, // Tampilkan popup konfirmasi
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat item list
  Widget _buildSettingsOption(String title, IconData icon) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: Icon(icon, color: Colors.grey),
          onTap: () {
            debugPrint("$title ditekan");
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
