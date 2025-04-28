package com.dias.dias.repository;

import com.dias.dias.model.AttendanceRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttendanceRecordRepository extends JpaRepository<AttendanceRecord, String> {
}