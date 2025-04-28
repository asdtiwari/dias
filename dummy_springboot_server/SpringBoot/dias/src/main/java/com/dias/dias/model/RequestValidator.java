package com.dias.dias.model;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class RequestValidator {
    @Id
    private String userId; // Primary key, also a foreign key to LoginCredentials or StudentRecord

    @Column(unique = true, nullable = false)
    private String loginSecretKey;

    @Column(unique = true, nullable = false)
    private String udid;

    @Column(nullable = false)
    private boolean isBlock;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ResetRequest resetRequest; // Enum: NONE, REQUEST, APPROVED

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role; // Enum: TEACHER, FACULTY, STUDENT

    public enum ResetRequest {
        NONE, REQUEST, APPROVED
    }

    public enum Role {
        TEACHER, FACULTY, STUDENT
    }
}
