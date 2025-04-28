package com.dias.dias.service.implementation;

import org.springframework.stereotype.Service;

import com.dias.dias.service.ResetService;

@Service
public class ResetServiceImplementation implements ResetService {

    @Override
    public void resetPassword(String username, String newPassword) {
        // Implement password reset logic (e.g., update password in the database)
    }

    @Override
    public String resetApplication(String userId) {
        return null;
    }
}
