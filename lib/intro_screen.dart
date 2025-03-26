import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 150), // Ganti dengan logo asli
            SizedBox(height: 20),
            Text(
              'FJB TELKOM\nTEL-U MARKETPLACE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Get Started', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
