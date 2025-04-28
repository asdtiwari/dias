package com.dias.dias.service;

public interface ResetService {
    void resetPassword(String username, String newPassword);
    String resetApplication(String userId);
}
