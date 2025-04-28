import 'package:flutter/material.dart';
import 'package:dias/services/device_status_service.dart';
import 'faculty_login_screen.dart';
import 'student_login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  Future<void> _onRoleSelected(String role) async {
    bool internetOn = await DeviceStatusService().isInternetAvailable();
    if (!mounted) return;
    if (!internetOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please connect to the internet.")),
      );
      return;
    }
    if (role == "faculty") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FacultyLoginScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Select Your Role",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () => _onRoleSelected("faculty"),
              child: const Text("Faculty"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () => _onRoleSelected("student"),
              child: const Text("Student"),
            ),
          ],
        ),
      ),
    );
  }
}
