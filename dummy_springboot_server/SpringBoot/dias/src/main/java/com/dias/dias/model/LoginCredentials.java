package com.dias.dias.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class LoginCredentials {
    @Id
    private String userId; // Primary key

    @Column(nullable = false)
    private String password; // Hashed password

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(nullable = false)
    private String mobile;

}
