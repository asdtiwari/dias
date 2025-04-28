import 'package:flutter/material.dart';
import 'package:dias/services/device_status_service.dart';
import '../services/keychain_service.dart';
import '../services/local_database_service.dart';
import '../services/auth_service.dart';
import 'role_selection_screen.dart';

class BlockedScreen extends StatefulWidget {
  final String userId;
  const BlockedScreen({super.key, required this.userId});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  bool _isLoading = false;

  Future<void> _resetApplication() async {
    setState(() => _isLoading = true);

    bool internet = await DeviceStatusService().isInternetAvailable();
    if (!internet) {
      _showSnack("Please connect to the internet.");
      setState(() => _isLoading = false);
      return;
    }

    final result = await AuthService().resetApplication(widget.userId);

    if (result == 'waiting') {
      _showSnack("Please wait for admin approval.");
    } else if (result == 'approved') {
      await KeychainService().clearCredentials();
      await LocalDatabaseService().clearAll();
      await KeychainService().clearBlockedStatus();
      _showSnack("Application reset. Logging out...");

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }

    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Your device is blocked.",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _resetApplication,
                      child: const Text("Reset Application"),
                    ),
                  ],
                ),
      ),
    );
  }
}
