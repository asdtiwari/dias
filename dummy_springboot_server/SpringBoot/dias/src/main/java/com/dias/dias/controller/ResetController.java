package com.dias.dias.controller;

import com.dias.dias.service.ResetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/faculty")
public class ResetController {
    @Autowired
    private ResetService resetService;

    @PostMapping("/reset")
    public ResetResponse resetApplication(@RequestBody ResetRequest request) {
        String status = resetService.resetApplication(request.getUserId());
        ResetResponse response = new ResetResponse();
        response.setStatus(status);
        return response;
    }
    
    public static class ResetRequest {
        private String userId;
        // Getters and setters...
        public String getUserId() { return userId; }
        public void setUserId(String userId) { this.userId = userId; }
    }
    
    public static class ResetResponse {
        private String status;
        // Getters and setters...
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
    }
}