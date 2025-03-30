import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          emailController.text = userDoc['email'] ?? '';
        });
      }
    }
  }

  void _updateProfile() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': nameController.text.trim(),
      });

      // 🔹 Update displayName di FirebaseAuth
      await user!.updateDisplayName(nameController.text.trim());
      await user!.reload(); // Refresh data user

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Profil berhasil diperbarui"), backgroundColor: Colors.green),
      );

      setState(() {
        isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundImage: AssetImage("assets/profile_placeholder.png")),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nama"),
              readOnly: !isEditing,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              readOnly: true,
            ),
            SizedBox(height: 20),
            isEditing
                ? ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Simpan"),
            )
                : ElevatedButton(
              onPressed: () => setState(() => isEditing = true),
              child: Text("Edit Profil"),
            ),
          ],
        ),
      ),
    );
  }
}
