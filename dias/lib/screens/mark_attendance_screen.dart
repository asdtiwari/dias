import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_scanner.dart';
import '../services/encryption_service.dart';
import '../services/local_database_service.dart';
import 'package:intl/intl.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  MarkAttendanceScreenState createState() => MarkAttendanceScreenState();
}

class MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String? _selectedCiphertext;
  final List<String> _scannedCiphertexts = [];
  final BLEScanner _bleScanner = BLEScanner();

  @override
  void initState() {
    super.initState();
    _checkBluetoothAndStartScanning();
  }

  Future<void> _checkBluetoothAndStartScanning() async {
    bool isBluetoothOn =
        await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;

    if (!isBluetoothOn) {
      _showBluetoothError();
      return;
    }

    _bleScanner.startScanning((ciphertext) {
      if (!_scannedCiphertexts.contains(ciphertext)) {
        if (!mounted) return;
        setState(() {
          _scannedCiphertexts.add(ciphertext);
        });
      }
    });
  }

  void _showBluetoothError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enable Bluetooth to scan for attendance"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markAttendance() async {
    if (_selectedCiphertext == null) return;

    String decrypted = EncryptionService().decrypt(_selectedCiphertext!);

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String studentClass = await LocalDatabaseService().getUserClass();
    String newCiphertext = "$decrypted-$studentClass-$currentDate";
    String encryptedNewCiphertext = EncryptionService().encrypt(newCiphertext);

    bool exists = await LocalDatabaseService().attendanceExists(
      encryptedNewCiphertext,
    );
    if (!mounted) return;

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance already marked"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await LocalDatabaseService().storeAttendance(encryptedNewCiphertext);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance marked successfully"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _bleScanner.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Mark Attendance",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _scannedCiphertexts.length,
              itemBuilder: (context, index) {
                String ciphertext = _scannedCiphertexts[index];
                String decrypted = EncryptionService().decrypt(ciphertext);
                String attendanceType = decrypted.substring(0, 1);
                String courseCode = decrypted.substring(1, 8);
                String roomNumber = decrypted.substring(8, 12);
                String displayText =
                    '($attendanceType) $courseCode - $roomNumber';

                return ListTile(
                  title: Text(
                    displayText,
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: Radio<String>(
                    value: ciphertext,
                    groupValue: _selectedCiphertext,
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _selectedCiphertext = value;
                      });
                    },
                    fillColor: WidgetStateColor.resolveWith(
                      (states) => Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedCiphertext != null ? _markAttendance : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey[900]!; // Light black when disabled
                  }
                  return Colors.grey[850]!; // Dark grey when enabled
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey[500]!; // Dark grey text for disabled
                  }
                  return Colors.white; // White text when enabled
                }),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              child: const Text("Mark Attendance"),
            ),
          ),
        ],
      ),
    );
  }
}
