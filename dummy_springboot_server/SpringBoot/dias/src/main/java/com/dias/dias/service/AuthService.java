package com.dias.dias.service;

import com.dias.dias.model.LoginCredentials;

public interface AuthService {
    boolean authenticate(String username, String password);
    void logout(String username);
    LoginCredentials loginFaculty(String username, String password);
}
