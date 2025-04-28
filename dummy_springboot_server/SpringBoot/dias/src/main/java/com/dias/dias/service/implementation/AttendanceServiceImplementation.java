package com.dias.dias.service.implementation;

import com.dias.dias.model.AttendanceRecord;
import com.dias.dias.repository.AttendanceRecordRepository;
import com.dias.dias.service.AttendanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AttendanceServiceImplementation implements AttendanceService {
    @Autowired
    private AttendanceRecordRepository attendanceRepository;

    @Override
    public List<AttendanceRecord> getAllAttendanceRecords() {
        return attendanceRepository.findAll();
    }

    @Override
    public AttendanceRecord getAttendanceRecordById(String id) {
        return attendanceRepository.findById(id).orElse(null);
    }

    @Override
    public AttendanceRecord addAttendanceRecord(AttendanceRecord attendanceRecord) {
        return attendanceRepository.save(attendanceRecord);
    }

    @Override
    public AttendanceRecord updateAttendanceRecord(String id, AttendanceRecord attendanceRecord) {
        if (attendanceRepository.existsById(id)) {
            attendanceRecord.setCipherText(id);
            return attendanceRepository.save(attendanceRecord);
        }
        return null;
    }

    @Override
    public void deleteAttendanceRecord(String id) {
        attendanceRepository.deleteById(id);
    }
}