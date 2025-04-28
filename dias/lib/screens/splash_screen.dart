import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:dias/services/device_status_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/keychain_service.dart';
import '../services/local_database_service.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import 'role_selection_screen.dart';
import 'faculty_home_screen.dart';
import 'student_home_screen.dart';
import 'blocked_screen.dart';
import 'fake_app_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _requestPermissions();

    bool bleCentralSupported = await FlutterBluePlus.isSupported;
    bool blePeripheralSupported = await blePeripheral.isSupported;

    if (!bleCentralSupported && !blePeripheralSupported) {
      _navigateToErrorScreen("Incompatible Device. Please Upgrade.");
      return;
    } else if (!bleCentralSupported || !blePeripheralSupported) {
      _showIncompatibilityDialog(
        bleCentralSupported
            ? "Advertising is not supported."
            : "Scanning is not supported.",
      );
    }

    Map<String, String>? credentials =
        await LocalDatabaseService().getCredentials();

    if (credentials == null) {
      credentials = await KeychainService().getCredentials();
      if (credentials != null) {
        await LocalDatabaseService().storeCredentials(credentials);
      }
    }

    bool isLegit = await SecurityService().isEnvironmentTrusted();
    
    if (!isLegit) {
      if (credentials != null && credentials.isNotEmpty) {
        final String userId = credentials['userId']!;
        await KeychainService().storeBlockedStatus(true);
        await LocalDatabaseService().storeBlockedStatus(true);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BlockedScreen(userId: userId)),
        );
        return;
      }
      _navigateToScreen(FakeAppScreen());
      return;
    }

    if (credentials != null && credentials.isNotEmpty) {
      _handleLogin(credentials);
    } else {
      _navigateToScreen(const RoleSelectionScreen());
    }
  }

  Future<void> _handleLogin(Map<String, String> credentials) async {
    final String userId = credentials['userId']!;
    final String userType = credentials['userType']!;

    final bool blocked = await _isDeviceBlocked(userId);
    if (blocked) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BlockedScreen(userId: userId)),
      );
      return;
    }

    final localProfile = await LocalDatabaseService().getUserProfile();

    if (localProfile.isEmpty) {
      final bool connectivityResult =
          await DeviceStatusService().isInternetAvailable();
      if (!connectivityResult) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your profile details are unavailable. Please connect to the internet to fetch your details.',
            ),
          ),
        );
        return;
      }
      Map<String, dynamic>? profile;
      if (userType == 'faculty') {
        profile = await AuthService().getFacultyProfile(userId);
      } else {
        profile = await AuthService().getStudentProfile(userId);
      }
      if (profile != null) {
        await LocalDatabaseService().setUserProfile(profile);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to fetch profile details. Please try again later.',
            ),
          ),
        );
        return;
      }
    }

    _navigateToScreen(
      userType == 'faculty'
          ? const FacultyHomeScreen()
          : const StudentHomeScreen(),
    );
  }

  Future<bool> _isDeviceBlocked(String userId) async {
    bool? localBlocked = await LocalDatabaseService().getBlockedStatus();
    if (localBlocked == true) return true;

    bool? keychainBlocked = await KeychainService().getBlockedStatus();
    if (keychainBlocked == true) return true;

    bool hasInternet = await DeviceStatusService().isInternetAvailable();
    if (!hasInternet) return false;

    bool isBlocked = await AuthService().checkBlockStatus(userId);
    if (isBlocked) {
      await KeychainService().storeBlockedStatus(true);
      await LocalDatabaseService().storeBlockedStatus(true);
    }
    return isBlocked;
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.storage, // for below android 10
      Permission.manageExternalStorage, // for above android 10
      Permission.photos, // for ios, If accessing photos
      Permission.mediaLibrary, // for ios If dealing with audio/video library
    ].request();
  }

  void _navigateToErrorScreen(String message) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showIncompatibilityDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Device Incompatibility',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
