package com.dias.dias.controller;

import com.dias.dias.model.AttendanceRecord;
import com.dias.dias.service.AttendanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/attendance")
public class AttendanceController {

    @Autowired
    private AttendanceService attendanceService;

    // Retrieve all attendance records
    @GetMapping
    public ResponseEntity<List<AttendanceRecord>> getAllAttendanceRecords() {
        List<AttendanceRecord> records = attendanceService.getAllAttendanceRecords();
        return ResponseEntity.ok(records);
    }

    // Retrieve a specific attendance record by its cipherText (ID)
    @GetMapping("/{id}")
    public ResponseEntity<AttendanceRecord> getAttendanceRecordById(@PathVariable String id) {
        AttendanceRecord record = attendanceService.getAttendanceRecordById(id);
        return ResponseEntity.ok(record);
    }

    // Add a new attendance record
    @PostMapping
    public ResponseEntity<AttendanceRecord> addAttendanceRecord(@RequestBody AttendanceRecord record) {
        AttendanceRecord createdRecord = attendanceService.addAttendanceRecord(record);
        return ResponseEntity.ok(createdRecord);
    }

    // Update an existing attendance record
    @PutMapping("/{id}")
    public ResponseEntity<AttendanceRecord> updateAttendanceRecord(
            @PathVariable String id,
            @RequestBody AttendanceRecord recordDetails) {
        AttendanceRecord updatedRecord = attendanceService.updateAttendanceRecord(id, recordDetails);
        return ResponseEntity.ok(updatedRecord);
    }

    // Delete an attendance record
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAttendanceRecord(@PathVariable String id) {
        attendanceService.deleteAttendanceRecord(id);
        return ResponseEntity.noContent().build();
    }
}
