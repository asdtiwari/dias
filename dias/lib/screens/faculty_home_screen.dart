import 'package:flutter/material.dart';
import 'advertising_active_screen.dart';
import 'view_profile_screen.dart';

class FacultyHomeScreen extends StatefulWidget {
  const FacultyHomeScreen({super.key});

  @override
  FacultyHomeScreenState createState() => FacultyHomeScreenState();
}

class FacultyHomeScreenState extends State<FacultyHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Faculty Home",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First Elevated Button
            SizedBox(
              width: 200, // This makes the button take up full width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ViewProfileScreen(role: "faculty"),
                    ),
                  );
                },
                child: const Text("View Profile"),
              ),
            ),

            const SizedBox(height: 16), // Add space between the buttons
            // Second Elevated Button
            SizedBox(
              width: 200, // This makes the button take up full width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdvertisingActiveScreen(),
                    ),
                  );
                },
                child: const Text("Host Attendance"),
              ),
            ),

            const SizedBox(height: 20), // Space after the second button
          ],
        ),
      ),
    );
  }
}
