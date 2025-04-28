package com.dias.dias.service;

import com.dias.dias.model.AttendanceRecord;
import java.util.List;

public interface AttendanceService {
    List<AttendanceRecord> getAllAttendanceRecords();
    AttendanceRecord getAttendanceRecordById(String id);
    AttendanceRecord addAttendanceRecord(AttendanceRecord attendanceRecord);
    AttendanceRecord updateAttendanceRecord(String id, AttendanceRecord attendanceRecord);
    void deleteAttendanceRecord(String id);
}
