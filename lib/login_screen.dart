import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart'; // Import halaman Home

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Email dan password tidak boleh kosong!");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        _showError("Silakan verifikasi email Anda terlebih dahulu.");
        await FirebaseAuth.instance.signOut(); // Logout user yang belum verifikasi
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Berhasil! 🎉', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_getErrorMessage(e));
    } catch (e) {
      _showError("Terjadi kesalahan. Coba lagi nanti.");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // User batal login
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login dengan Google Berhasil! 🎉', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      _showError("Login dengan Google gagal: ${e.toString()}");
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "Email tidak terdaftar. Silakan daftar terlebih dahulu.";
      case 'wrong-password':
        return "Password salah. Silakan coba lagi!";
      case 'invalid-email':
        return "Format email tidak valid!";
      case 'user-disabled':
        return "Akun ini telah dinonaktifkan.";
      case 'too-many-requests':
        return "Terlalu banyak percobaan login. Silakan coba lagi nanti.";
      default:
        return "Login gagal. Periksa kembali email dan password Anda.";
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _resetPassword() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      _showError("Masukkan email untuk reset password!");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showError("Link reset password telah dikirim ke email Anda!");
    } catch (e) {
      _showError("Terjadi kesalahan saat mengirim email reset password.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 20),
            Text(
              'Masuk ke Akun Anda',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password', suffixIcon: Icon(Icons.visibility)),
              obscureText: true,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: Text('Lupa Password?', style: GoogleFonts.poppins(color: Colors.blue)),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: _login,
              child: Text('Masuk', style: GoogleFonts.poppins(color: Colors.white)),
            ),
            SizedBox(height: 10),
            // Tombol Login dengan Google
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                side: BorderSide(color: Colors.black),
              ),
              onPressed: _signInWithGoogle,
              icon: Image.asset('assets/google_logo.png', height: 24),
              label: Text('Login dengan Google', style: GoogleFonts.poppins(color: Colors.black)),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Belum punya akun? Daftar', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }
}
