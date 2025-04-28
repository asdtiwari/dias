import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../services/keychain_service.dart';
import 'role_selection_screen.dart';
import '../services/device_status_service.dart';

class ViewProfileScreen extends StatefulWidget {
  final String role;

  const ViewProfileScreen({super.key, required this.role});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  Map<String, dynamic> _profileData = {};
  bool _isClassEditable = false;
  final TextEditingController _classController = TextEditingController();
  bool _isLoadingReset = false;
  bool _isLoadingClassChange = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final data = await LocalDatabaseService().getUserProfile();
    setState(() {
      _profileData = data;
      _classController.text = data['class'] ?? '';
    });
  }

  Future<void> _resetApplication() async {
    setState(() {
      _isLoadingReset = true; // <-- For circular progress loader
    });

    bool internetOn = await DeviceStatusService().isInternetAvailable();
    if (!mounted) return;
    if (!internetOn) {
      setState(() {
        _isLoadingReset = false; // <-- For circular progress loader
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please connect to the internet.")),
      );
      return;
    }
    String userId = await LocalDatabaseService().getUserId();
    final result = await AuthService().resetApplication(userId);
    if (!mounted) return;
    if (result == "server error") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server is not responding, Try again...")),
      );
    } else if (result == 'waiting') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait for admin approval.")),
      );
    } else if (result == 'approved') {
      await KeychainService().clearCredentials();
      await LocalDatabaseService().clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application reset successfully.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
    setState(() {
      _isLoadingReset = false;
    });
  }

  Future<void> _handleClassChange() async {
    setState(() {
      _isLoadingClassChange = true;
    });
    bool internetOn = await DeviceStatusService().isInternetAvailable();
    if (!mounted) return;
    if (!internetOn) {
      setState(() {
        _isLoadingReset = false; // <-- For circular progress loader
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please connect to the internet.")),
      );
      return;
    }

    String userId = await LocalDatabaseService().getUserId();
    if (!_isClassEditable) {
      final status = await AuthService().requestClassChange(userId);
      setState(() {
        _isLoadingClassChange = false;
      });

      if (!mounted) return;
      if (status == "server error") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server is not responding, Try again..."),
          ),
        );
      } else if (status == 'waiting') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please wait for admin approval.")),
        );
      } else if (status == 'approved') {
        setState(() => _isClassEditable = true);
      }
    } else {
      final updatedClass = _classController.text;
      final status = await AuthService().updateClass(userId, updatedClass);

      if (!mounted) return;
      if (status == "server error") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server is not responding, Try again..."),
          ),
        );
      }
      if (status == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Class updated successfully.")),
        );
        setState(() => _isClassEditable = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update class.")),
        );
      }
      setState(() {
        _isLoadingClassChange = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role.toLowerCase() == 'student';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "View Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _profileData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                    child: Card(
                      color: Colors.grey[900],
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _profileTile("Full Name", _profileData['name']),
                            _profileTile("Role", _profileData['role']),
                            const SizedBox(height: 20),
                            _profileTile("Email", _profileData['email']),
                            _profileTile("Mobile", _profileData['mobile']),
                            const SizedBox(height: 16),
                            if (isStudent) ...[
                              _profileTile(
                                "Scholar No",
                                _profileData['scholar_no'],
                              ),
                              _profileTile(
                                "Enrollment",
                                _profileData['enrollment'],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _classController,
                                enabled: _isClassEditable,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Class',
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _isLoadingClassChange
                                  ? const Center(
                                    child: SizedBox(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : _customButton(
                                    onPressed: _handleClassChange,
                                    text:
                                        _isClassEditable
                                            ? "Submit New Class"
                                            : "Change Class",
                                  ),
                            ] else ...[
                              _profileTile("User ID", _profileData['userId']),
                            ],
                            const SizedBox(height: 20),
                            _isLoadingReset
                                ? const Center(
                                  child: SizedBox(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : _customButton(
                                  onPressed: _resetApplication,
                                  text: "Reset Application",
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _profileTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _customButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
