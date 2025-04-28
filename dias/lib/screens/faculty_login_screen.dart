import 'package:flutter/material.dart';
import 'package:dias/services/device_status_service.dart';
import '../services/auth_service.dart';
import '../services/keychain_service.dart';
import '../services/local_database_service.dart';
import 'splash_screen.dart';

class FacultyLoginScreen extends StatefulWidget {
  const FacultyLoginScreen({super.key});

  @override
  FacultyLoginScreenState createState() => FacultyLoginScreenState();
}

class FacultyLoginScreenState extends State<FacultyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // <-- For circular progress loader

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // <-- For circular progress loader
      });

      bool internetOn = await DeviceStatusService().isInternetAvailable();
      if (!mounted) return;
      if (!internetOn) {
        setState(() {
          _isLoading = false; // <-- For circular progress loader
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please connect to the internet.")),
        );
        return;
      }

      final response = await AuthService().loginFaculty(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (response != null) {
        if (response.containsKey('error')) {
          setState(() {
            _isLoading = false; // <-- For circular progress loader
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Server is not responding, Try again..."),
            ),
          );
        } else {
          final Map<String, String> credentials = {
            'loginSecretKey': response['loginSecretKey'],
            'userId': response['userId'],
            'userType': 'faculty',
          };

          await KeychainService().saveCredentials(credentials);
          await LocalDatabaseService().storeCredentials(credentials);

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid user")));
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Faculty Login",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Faculty ID",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Faculty ID";
                  }
                  final regex = RegExp(r'^\d{8}$');
                  if (!regex.hasMatch(value)) {
                    return "Faculty ID must be 8 digits";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter password";
                  }
                  if (value.length < 8 || value.length > 10) {
                    return "Password must be 8–10 characters";
                  }
                  final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
                  final hasLower = RegExp(r'[a-z]').hasMatch(value);
                  final hasDigit = RegExp(r'\d').hasMatch(value);
                  final hasSpecial = RegExp(
                    r'[!@#$%^&*(),.?":{}|<>]',
                  ).hasMatch(value);

                  if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
                    return "Password must include uppercase, lowercase, digit, and special char";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator() // <-- For circular progress loader
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
