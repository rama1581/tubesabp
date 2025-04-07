import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? profileImageUrl; // 🔹 Simpan URL gambar profil
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          emailController.text = userDoc['email'] ?? '';
          profileImageUrl = userDoc['profileImageUrl'] ?? null;
        });
      }
    }
  }

  // 🔹 Upload Gambar ke Cloudinary
  Future<String?> _uploadImage(File imageFile) async {
    const cloudName = "dagsegfxm"; // 🔹 Ganti dengan Cloud Name dari Cloudinary
    const uploadPreset = "telumarketplace"; // 🔹 Buat Upload Preset di Cloudinary

    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseData);

    if (response.statusCode == 200) {
      return jsonResponse["secure_url"];
    } else {
      print("⚠️ Gagal mengunggah gambar: ${jsonResponse['error']['message']}");
      return null;
    }
  }

  // 🔹 Pilih & Upload Gambar
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String? imageUrl = await _uploadImage(imageFile);

    if (imageUrl != null && user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'profileImageUrl': imageUrl,
      });

      setState(() {
        profileImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Foto profil berhasil diperbarui"), backgroundColor: Colors.green),
      );
    }
  }

  void _updateProfile() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': nameController.text.trim(),
      });

      await user!.updateDisplayName(nameController.text.trim());
      await user!.reload();

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
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B0000), Color(0xFFB22222)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 🔹 Avatar dengan ikon tambah
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : AssetImage("assets/profile_placeholder.png") as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // 🔹 Card Profil
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField("Nama", nameController, !isEditing),
                      SizedBox(height: 10),
                      _buildTextField("Email", emailController, true),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 🔹 Tombol Simpan/Edit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEditing ? _updateProfile : () => setState(() => isEditing = true),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Color(0xFFB22222),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: Text(
                    isEditing ? "Simpan" : "Edit Profil",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool readOnly) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      readOnly: readOnly,
    );
  }
}
