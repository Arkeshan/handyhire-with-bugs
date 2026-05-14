package com.example.handyhirebackend.auth.model;

public class LoginResponse {

    private String status;
    private String role;
    private String message;
    private Long userId;

    public LoginResponse() {}

    public LoginResponse(String status, String role, String message, Long userId) {
        this.status = status;
        this.role = role;
        this.message = message;
        this.userId = userId;
    }

    public LoginResponse(String status, String role, String message) {
        this(status, role, message, null);
    }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
}
