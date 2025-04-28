import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/device_status_service.dart';

class AuthService {
  // Base URL is set to your server’s API endpoint.
  final String baseUrl =
      "http://digital-intelligent-attendance-system.duckdns.org:8081/api";

  /// Logs in a faculty member.
  Future<Map<String, dynamic>?> loginFaculty(
    String username,
    String password,
  ) async {
    //final String udid = await FlutterUdid.consistentUdid;
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/faculty/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": username,
              "password": password,
              "udid": udid,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return {"error": "Server is not responding"};
    }
  }

  /// Logs in a student.
  Future<Map<String, dynamic>?> loginStudent({
    required String scholarId,
    required String enrollment,
    required String firstName,
    required String lastName,
    required String studentClass,
    required String email,
    required String mobile,
  }) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/student/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "scholarId": scholarId,
              "enrollment": enrollment,
              "firstName": firstName,
              "lastName": lastName,
              "studentClass": studentClass,
              "email": email,
              "udid": udid,
              "mobile": mobile,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return {"error": "Server is not responding"};
    }
  }

  /// Uploads attendance and then calls syncAttendance to retrieve the latest data.
  /// Returns the syncAttendance response as a Map.
  Future<Map<String, dynamic>?> uploadAttendance(
    List<String> attendanceList,
    String userId,
  ) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final uploadResponse = await http
          .post(
            Uri.parse("$baseUrl/student/attendance/upload"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "attendance": attendanceList,
              "udid": udid,
              "userId": userId,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (uploadResponse.statusCode == 200) {
        // After successful upload, call syncAttendance and return its response.
        return await syncAttendance(userId);
      }
      return null;
    } catch (e) {
      return {'error': "server error"};
    }
  }

  /// Fetches the attendance sync data from the server.
  Future<Map<String, dynamic>?> syncAttendance(String userId) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/student/attendance/sync"),
            headers: {
              "Authorization": "Bearer $userId",
              "x-device-udid": udid,
              "Content-Type": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return {'error': 'server error'};
    }
  }

  /// Retrieves the faculty profile from the server.
  Future<Map<String, dynamic>?> getFacultyProfile(String userId) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/faculty/profile"),
            headers: {
              "Authorization": "Bearer $userId",
              "x-device-udid": udid,
              "Content-Type": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the student profile from the server.
  Future<Map<String, dynamic>?> getStudentProfile(String userId) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/student/profile"),
            headers: {
              "Authorization": "Bearer $userId",
              "x-device-udid": udid,
              "Content-Type": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sends a reset request to the server.
  /// The server returns a status: 'waiting' if admin approval is pending, or 'approved' if reset is allowed.
  Future<String> resetApplication(String userId) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/user/reset"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"userId": userId, "udid": udid}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] as String;
      }
      return "error";
    } catch (e) {
      return "server error";
    }
  }

  /// Checks if the user is blocked by calling the server.
  Future<bool> checkBlockStatus(String userId) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/user/blockStatus"),
            headers: {
              "Authorization": "Bearer $userId",
              "x-device-udid": udid,
              "Content-Type": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["blocked"] as bool;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// REQUEST: Initiates a class change request.
  /// Returns a string status ("waiting", "approved", or "error").
  Future<String> requestClassChange(String userId) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/student/class-change/request"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"userId": userId, "udid": udid}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Expected response: { "status": "waiting" } or { "status": "approved" }
        return data["status"] as String;
      }
      return "error";
    } catch (e) {
      return "server error";
    }
  }

  /// UPDATE: Once admin approves, updates the user's class.
  /// Returns true if the update is successful.
  Future<String> updateClass(String userId, String newClass) async {
    final String udid = await DeviceStatusService().getDeviceId() ?? "";
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/student/class-change/update"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "userId": userId,
              "udid": udid,
              "newClass": newClass,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException("Server did not respond");
            },
          );
      if (response.statusCode == 200) {
        // Expected response: { "success": true } if update is successful.
        return "success";
      }
      return "error";
    } catch (e) {
      return "server error";
    }
  }
}
