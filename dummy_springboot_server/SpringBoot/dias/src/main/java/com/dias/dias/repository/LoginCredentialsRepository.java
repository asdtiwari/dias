package com.dias.dias.repository;

import com.dias.dias.model.LoginCredentials;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LoginCredentialsRepository extends JpaRepository<LoginCredentials, String> {
}