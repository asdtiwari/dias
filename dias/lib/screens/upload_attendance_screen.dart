import 'package:flutter/material.dart';
import 'package:dias/services/device_status_service.dart';
import '../services/local_database_service.dart';
import '../services/auth_service.dart';
import '../services//encryption_service.dart';

class UploadAttendanceScreen extends StatefulWidget {
  const UploadAttendanceScreen({super.key});

  @override
  UploadAttendanceScreenState createState() => UploadAttendanceScreenState();
}

class UploadAttendanceScreenState extends State<UploadAttendanceScreen> {
  List<String> _attendanceList = [];
  List<Map<String, dynamic>> _attendanceTable = [];
  String _lastSync = "";
  List<String> _encryptedList = [];
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    _encryptedList = await LocalDatabaseService().getAttendanceList();
    List<String> decryptedList = [];

    for (String encrypted in _encryptedList) {
      try {
        String decrypted = EncryptionService().decrypt(encrypted);
        decryptedList.add(decrypted);
      } catch (e) {
        // Optionally handle decryption errors
        debugPrint("Decryption failed for an entry: $e");
      }
    }

    if (!mounted) return;
    setState(() {
      _attendanceList = decryptedList;
    });
  }

  Future<void> _uploadAttendance() async {
    setState(() {
      _isloading = true;
    });
    bool internetOn = await DeviceStatusService().isInternetAvailable();
    if (!mounted) return;
    if (!internetOn) {
      _showSnack("Please connect to the internet.");
      return;
    }

    String? userId = await LocalDatabaseService().getUserId();
    if (userId == "") {
      if (!mounted) return;
      _showSnack("User ID not found.");
      return;
    }

    final response = await AuthService().uploadAttendance(
      _encryptedList,
      userId,
    );
    if (!mounted) return;
    if (response != null) {
      if (response.containsKey('error')) {
        _showSnack("Server is not responding. Try again...");
      } else {
        List<dynamic> tableDynamic = response['table'];
        List<Map<String, dynamic>> tableData =
            tableDynamic.cast<Map<String, dynamic>>();

        setState(() {
          _attendanceTable = tableData;
          _lastSync = response['lastSync'];
        });

        await LocalDatabaseService().updateAttendanceTable(_attendanceTable);
        await LocalDatabaseService().setLastSync(_lastSync);
        await LocalDatabaseService().clearAttendance();
        if (!mounted) return;
        setState(() {
          _attendanceList = [];
        });
        _showSnack("Attendance uploaded");
      }
    } else {
      _showSnack("Upload failed");
    }
    setState(() {
      _isloading = false;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _attendanceList.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload Attendance",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pending attendance count: ${_attendanceList.length}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Pending Attendance List
            Expanded(
              child:
                  _attendanceList.isEmpty
                      ? const Center(
                        child: Text(
                          "No attendance to upload.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _attendanceList.length,
                        itemBuilder: (context, index) {
                          final raw = _attendanceList[index];

                          // Extracting info from the string
                          final typeChar = raw[0];
                          final type = typeChar == 'T' ? 'Theory' : 'Practical';
                          final subjectCode = raw.substring(
                            1,
                            8,
                          ); // e.g., CS3CO45
                          final roomNumber = raw.substring(8, 12); // e.g., V005

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                "$type - $subjectCode - $roomNumber",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Upload Button
            const SizedBox(height: 20),
            _isloading
                ? const CircularProgressIndicator()
                : Center(
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? _uploadAttendance : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey[900]!;
                        }
                        return Colors.grey[850]!;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey[500]!;
                        }
                        return Colors.white;
                      }),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    child: const Text("Upload Attendance"),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
