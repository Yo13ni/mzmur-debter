// lib/screens/loading_page.dart
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700, // Match your app's theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'መዝሙሮችን በመጫን ላይ........',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // Optional: Use Google Fonts if you're using it
                // fontFamily: GoogleFonts.notoSansEthiopic().fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'የመዝሙር ደብተር',
              style: TextStyle(
                color: Colors.teal.shade100,
                fontSize: 16,
                // Optional: Use Google Fonts
                // fontFamily: GoogleFonts.notoSansEthiopic().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}