import 'package:flutter/material.dart';

class FakeAppScreen extends StatefulWidget {
  const FakeAppScreen({super.key});

  @override
  State<FakeAppScreen> createState() => _FakeAppScreenState();
}

class _FakeAppScreenState extends State<FakeAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // This ensures both vertical and horizontal centering
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important to keep the column tight
          children: const [
            Text(
              'Ensure that you are using original App and granted all required permission.\n'
              'Your device or app environment failed our security checks.\n'
              'Please contact support.',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign:
                  TextAlign.center, // Optional: aligns text for readability
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
