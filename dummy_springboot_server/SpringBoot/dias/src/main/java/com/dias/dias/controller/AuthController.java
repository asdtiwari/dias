package com.dias.dias.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class AuthController {

    @PostMapping("/faculty/login")
    public ResponseEntity<Map<String, String>> facultyLogin(@RequestBody FacultyLoginRequest request) {
        System.out.println(request);

        // Creating a dummy JSON response
        Map<String, String> response = new HashMap<>();
        response.put("loginSecretKey", "faculty_secret_key");
        response.put("userId", request.getUsername());
        response.put("userType", "faculty");

        return ResponseEntity.ok(response);
    }

    @Getter
    @Setter
    @ToString
    public static class FacultyLoginRequest {
        private String username;
        private String password;
        private String udid;
    }

    @PostMapping("/student/login")
    public ResponseEntity<Map<String, String>> studentLogin(@RequestBody StudentLoginRequest request) {
        System.out.println(request);

        // Creating a dummy JSON response
        Map<String, String> response = new HashMap<>();
        response.put("loginSecretKey", "student_secret_key");
        response.put("userId", request.getScholarId());
        response.put("userType", "student");

        return ResponseEntity.ok(response);
    }

    @Getter
    @Setter
    @ToString
    public static class StudentLoginRequest {
        private String scholarId;
        private String enrollment;
        private String firstName;
        private String lastName;
        private String studentClass;
        private String email;
        private String udid;
        private String mobile;
    }

    @PostMapping("/user/reset")
    public ResponseEntity<Map<String, String>> resetRequest(@RequestBody ResetRequest request) {
        System.out.println(request);

        // Creating a dummy JSON response
        Map<String, String> response = new HashMap<>();
        response.put("status", "approved");

        return ResponseEntity.ok(response);
    }

    @Getter
    @Setter
    @ToString
    public static class ResetRequest {
        private String userId;
        private String udid;
    }

    @PostMapping("/student/attendance/upload")
    public ResponseEntity<Map<String, String>> uploadRequest(@RequestBody AttendanceUploadRequest request) {
        System.out.println(request);
        System.out.println(decrypt(request.getAttendance().get(0)));
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Attendance upload successful");
        return ResponseEntity.ok(response);
    }

    @Getter
    @Setter
    @ToString
    public static class AttendanceUploadRequest {
        private List<String> attendance;
        private String udid;
        private String userId;
    }

    @GetMapping("/student/attendance/sync")
    public ResponseEntity<Map<String, Object>> syncAttendance(
            @RequestHeader("Authorization") String authorization,
            @RequestHeader("x-device-udid") String deviceUdid) {

        // Extract userId from Authorization header (e.g., "Bearer testUserId")
        String userId = authorization.replace("Bearer ", "");
        System.out.println("Authorization: " + authorization + ", userId: " + userId + ", deviceUdid: " + deviceUdid);

        // Create dummy attendance table data
        List<Map<String, Object>> table = new ArrayList<>();

        Map<String, Object> row1 = new HashMap<>();
        row1.put("courseCode", "CS101");
        row1.put("totalCount", 30);
        row1.put("present", 25);
        table.add(row1);

        Map<String, Object> row2 = new HashMap<>();
        row2.put("courseCode", "Python CS3CO35");
        row2.put("totalCount", 28);
        row2.put("present", 27);
        table.add(row2);

        // Create the response map with dummy values
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Attendance sync successful");
        response.put("userId", userId);
        response.put("lastSync", "2023-04-26 12:00:00"); // Dummy timestamp
        response.put("table", table);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/blockStatus")
    public ResponseEntity<Map<String, Object>> checkBlockStatus(
            @RequestHeader("Authorization") String authorization,
            @RequestHeader("x-device-udid") String deviceUdid) {

        // Extract userId from Authorization header
        String userId = authorization.replace("Bearer ", "");

        System.out.println(authorization + " " + userId + " " + deviceUdid);

        // Create response
        Map<String, Object> response = new HashMap<>();
        response.put("blocked", false);
        response.put("userId", userId);

        return ResponseEntity.ok(response);
    }

    private static final int KEY = 59;

    public static String decrypt(String cipherText) {
        StringBuilder decrypted = new StringBuilder();

        for (char c : cipherText.toCharArray()) {
            decrypted.append((char) (c ^ KEY));
        }

        return decrypted.toString();
    }

    @GetMapping("/faculty/profile")
    public ResponseEntity<Map<String, Object>> getFacultyProfile(
            @RequestHeader("Authorization") String authHeader,
            @RequestHeader("x-device-udid") String deviceUdid) {

        // Dummy verification logic (in production, validate token and UDID properly)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid token"));
        }

        String userId = authHeader.substring(7); // Remove "Bearer " from header

        // Dummy profile data
        Map<String, Object> profile = new HashMap<>();
        profile.put("userId", userId);
        profile.put("email", "faculty_" + userId + "@example.com");
        profile.put("name", "Dr. John Doe");
        profile.put("mobile", "9876543210");
        profile.put("role", "faculty");

        return ResponseEntity.ok(profile);
    }

    @GetMapping("/student/profile")
    public ResponseEntity<Map<String, Object>> getStudentProfile(
            @RequestHeader("Authorization") String authHeader,
            @RequestHeader("x-device-udid") String deviceUdid) {

        // Dummy validation
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid token"));
        }

        String userId = authHeader.substring(7); // Extract userId from token

        // Dummy student profile data
        Map<String, Object> profile = new HashMap<>();
        profile.put("userId", userId);
        profile.put("email", "student_" + userId + "@example.com");
        profile.put("name", "Jane Student");
        profile.put("mobile", "9876543210");
        profile.put("role", "student");
        profile.put("scholar_no", "SCH123456");
        profile.put("enrollment", "ENR2023CSE001");
        profile.put("class", "CSE-6A");

        return ResponseEntity.ok(profile);
    }

    @PostMapping("/student/class-change/request")
    public ResponseEntity<Map<String, String>> requestClassChange(@RequestBody Map<String, String> request) {
        String userId = request.get("userId");
        String udid = request.get("udid");

        if (userId == null || udid == null) {
            return ResponseEntity.badRequest().body(Map.of("status", "error", "message", "Missing userId or udid"));
        }

        // Simulate checking if request is already approved or pending
        // For now, return "waiting" as dummy status
        String status = "approved"; // Or "approved" based on some condition or logic

        return ResponseEntity.ok(Map.of("status", status));
    }

    @PostMapping("/student/class-change/update")
    public ResponseEntity<Map<String, Boolean>> updateStudentClass(@RequestBody Map<String, String> request) {
        String userId = request.get("userId");
        String udid = request.get("udid");
        String newClass = request.get("newClass");

        if (userId == null || udid == null || newClass == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false));
        }

        // Simulate updating the class in the database (dummy logic for now)
        System.out.println("Updating class for user: " + userId + " to new class: " + newClass + " with UDID: " + udid);

        // Always return success as true for this dummy implementation
        return ResponseEntity.ok(Map.of("success", true));
    }
}
