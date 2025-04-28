import 'package:flutter/material.dart';
import 'package:dias/services/device_status_service.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  ViewAttendanceScreenState createState() => ViewAttendanceScreenState();
}

class ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  List<Map<String, dynamic>> _attendanceTable = [];
  String _lastSync = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocalAttendance();
  }

  Future<void> _loadLocalAttendance() async {
    try {
      List<Map<String, dynamic>> table =
          await LocalDatabaseService().getAttendanceTable();
      String lastSync = await LocalDatabaseService().getLastSync();
      if (!mounted) return;
      setState(() {
        _attendanceTable = table;
        _lastSync = lastSync;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading local attendance: $e")),
      );
    }
  }

  Future<void> _syncAttendance() async {
    setState(() {
      _isLoading = true;
    });
    bool internetOn = await DeviceStatusService().isInternetAvailable();
    if (!mounted) return;

    if (!internetOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please connect to the internet.")),
      );
      return;
    }

    String? userId = await LocalDatabaseService().getUserId();
    if (userId == "") {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID not found.")));
      return;
    }

    final response = await AuthService().syncAttendance(userId);
    if (!mounted) return;

    if (response != null) {
      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server is not responding. Try again..."),
          ),
        );
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
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sync failed, please try again")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "View Attendance",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Last Sync: $_lastSync",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.grey[900],
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.grey[850],
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        "Course Code",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Total Count",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Present",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Percentage",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  rows:
                      _attendanceTable.map((row) {
                        double percentage =
                            (row["present"] / row["totalCount"]) * 100;
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                row["courseCode"].toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                row["totalCount"].toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                row["present"].toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                percentage.toStringAsFixed(2),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _syncAttendance,
                  child: const Text("Sync"),
                ),
          ],
        ),
      ),
    );
  }
}
