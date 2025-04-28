package com.dias.dias.repository;

import com.dias.dias.model.StudentRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentRecordRepository extends JpaRepository<StudentRecord, String> {
}