package com.dias.dias.model;

import jakarta.persistence.*;
import java.sql.Time;
import java.sql.Date;
import lombok.*;

@Entity
@Getter
@Setter
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class AttendanceRecord {
    @Id
    private String cipherText; // Primary key (encrypted attendance info)

    @Column(nullable = false)
    private String userId; // Foreign key to LoginCredentials

    @Column(nullable = false)
    private String scholarId; // Foreign key to StudentRecord

    @Column(nullable = false)
    private String courseCode;

    @Column(nullable = false)
    private String roomNo;

    @Column(nullable = false)
    private Time sessionStartTime;

    @Column(nullable = false)
    private Date sessionDate;
}
