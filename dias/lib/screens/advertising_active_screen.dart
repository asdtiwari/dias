import 'package:flutter/material.dart';
import 'package:dias/services/device_status_service.dart';
import '../services/ble_advertiser.dart';
import '../services/encryption_service.dart';
import '../services/local_database_service.dart';

class AdvertisingActiveScreen extends StatefulWidget {
  const AdvertisingActiveScreen({super.key});

  @override
  AdvertisingActiveScreenState createState() => AdvertisingActiveScreenState();
}

class AdvertisingActiveScreenState extends State<AdvertisingActiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _sessionStartController = TextEditingController();

  // Internal secret key remains unchanged
  final String _internalSecretKey = "=^~0";

  bool _isAdvertising = false;

  // New: Attendance type radio group ("T" for Theory, "P" for Practical)
  String? _attendanceType; // Must be "T" or "P"

  bool _isValidTime(String input) {
    final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return timeRegex.hasMatch(input);
  }

  Future<void> _hostAttendance() async {
    // Validate entire form, including attendance type selection.
    if (_formKey.currentState?.validate() ?? false) {
      if (_attendanceType == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select Theory or Practical.")),
        );
        return;
      }

      // Convert fields to uppercase
      String subjectCode = _subjectCodeController.text.toUpperCase();
      String roomNumber = _roomNumberController.text.toUpperCase();
      String sessionStart = _sessionStartController.text.toUpperCase();

      bool btOn = await DeviceStatusService().isBluetoothOn();
      if (!btOn) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bluetooth is turned off. Please turn it on."),
          ),
        );
        return;
      }

      String userId = await LocalDatabaseService().getUserId();
      if (userId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User ID not found.")));
        return;
      }

      // Concatenate the attendance type as the first character, then the rest of the fields:
      String dataToEncrypt =
          _attendanceType! +
          subjectCode +
          roomNumber +
          sessionStart +
          userId +
          _internalSecretKey;

      String ciphertext = EncryptionService().encrypt(dataToEncrypt);

      try {
        await BLEAdvertiser().startAdvertising(ciphertext);
        if (!mounted) return;
        setState(() {
          _isAdvertising = true;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isAdvertising = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Advertising failed: $e")));
      }
    }
  }

  Future<void> _stopHosting() async {
    try {
      await BLEAdvertiser().stopAdvertising();
      if (!mounted) return;
      setState(() {
        _isAdvertising = false;
      });
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _subjectCodeController.dispose();
    _roomNumberController.dispose();
    _sessionStartController.dispose();
    _stopHosting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Host Attendance"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _isAdvertising
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Attendance is being hosted",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _stopHosting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Stop Hosting"),
                      ),
                    ],
                  ),
                )
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Subject Code Input Field
                      TextFormField(
                        controller: _subjectCodeController,
                        style: const TextStyle(color: Colors.white),
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: "Subject Code",
                          hintText: "e.g. CS3CO45",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          final regex = RegExp(r'^[A-Z]{2}[A-Z0-9]{5}$');
                          if (value == null ||
                              !regex.hasMatch(value.toUpperCase())) {
                            return "Format must be like CS3CO45";
                          }
                          return null;
                        },
                      ),
                      // Room Number Input Field
                      TextFormField(
                        controller: _roomNumberController,
                        style: const TextStyle(color: Colors.white),
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: "Room Number",
                          hintText: "e.g. V005",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          final regex = RegExp(r'^[A-Z]\d{3}$');
                          if (value == null ||
                              !regex.hasMatch(value.toUpperCase())) {
                            return "Format must be like V005";
                          }
                          return null;
                        },
                      ),
                      // Session Start Time Input Field
                      TextFormField(
                        controller: _sessionStartController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Session Start Time",
                          hintText: "e.g. 14:30 (24-hour)",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || !_isValidTime(value)) {
                            return "Enter valid time in 24h format HH:MM";
                          }
                          return null;
                        },
                      ),
                      // New: Radio Buttons for Attendance Type
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: FormField<String>(
                          initialValue: _attendanceType,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Select Theory or Practical";
                            }
                            return null;
                          },
                          builder: (FormFieldState<String> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  "Attendance Type",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Radio<String>(
                                      value: "T",
                                      groupValue: _attendanceType,
                                      onChanged: (value) {
                                        setState(() {
                                          _attendanceType = value;
                                          state.didChange(value);
                                        });
                                      },
                                    ),
                                    const Text(
                                      "Theory",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 20),
                                    Radio<String>(
                                      value: "P",
                                      groupValue: _attendanceType,
                                      onChanged: (value) {
                                        setState(() {
                                          _attendanceType = value;
                                          state.didChange(value);
                                        });
                                      },
                                    ),
                                    const Text(
                                      "Practical",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                if (state.hasError)
                                  Text(
                                    state.errorText!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _hostAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Host Attendance"),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
