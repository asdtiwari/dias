import 'package:flutter/material.dart';
import 'package:dias/services/device_status_service.dart';
import '../services/auth_service.dart';
import '../services/keychain_service.dart';
import '../services/local_database_service.dart';
import 'splash_screen.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  StudentLoginScreenState createState() => StudentLoginScreenState();
}

class StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _scholarIdController = TextEditingController();
  final TextEditingController _enrollmentController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _studentClassController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  bool _isLoading = false;

  String? _validateScholarId(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (!RegExp(r'^\d{7}$').hasMatch(value)) {
      return "Must be exactly 7 digits";
    }
    return null;
  }

  String? _validateEnrollment(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z0-9]{12,13}$').hasMatch(value)) {
      return "Must be 12 or 13 alphanumeric characters";
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return "Only alphabets allowed";
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Must be exactly 10 digits";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
      return "Invalid email format";
    }
    return null;
  }

  String? _validateClass(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (value.length > 10) return "Max 10 characters allowed";
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      bool internetOn = await DeviceStatusService().isInternetAvailable();
      if (!mounted) return;

      if (!internetOn) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please connect to the internet.")),
        );
        return;
      }
      final response = await AuthService().loginStudent(
        scholarId: _scholarIdController.text.toUpperCase(),
        enrollment: _enrollmentController.text.toUpperCase(),
        firstName: _firstNameController.text.toUpperCase(),
        lastName: _lastNameController.text.toUpperCase(),
        studentClass: _studentClassController.text.toUpperCase(),
        email: _emailController.text,
        mobile: _mobile.text.toUpperCase(),
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
            'userType': 'student',
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
        ).showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }
  }

  @override
  void dispose() {
    _scholarIdController.dispose();
    _enrollmentController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentClassController.dispose();
    _emailController.dispose();
    _mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Student Login",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _scholarIdController,
                decoration: const InputDecoration(
                  labelText: "Scholar ID",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: _validateScholarId,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _enrollmentController,
                decoration: const InputDecoration(
                  labelText: "Enrollment Number (Optional)",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: _validateEnrollment,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: _validateName,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: _validateName,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _studentClassController,
                decoration: const InputDecoration(
                  labelText: "Class",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: _validateClass,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: _validateEmail,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _mobile,
                decoration: const InputDecoration(
                  labelText: "Mobile",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validateMobile,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Login"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
