package com.example.handyhirebackend.common.dto;

public class ApiResponse {

    private String status;
    private String message;
    private Object data;

    public ApiResponse() {}

    public ApiResponse(String status, String message) {
        this.status = status;
        this.message = message;
    }

    public ApiResponse(String status, String message, Object data) {
        this.status = status;
        this.message = message;
        this.data = data;
    }

    public static ApiResponse success(String message) {
        return new ApiResponse("SUCCESS", message);
    }

    public static ApiResponse success(String message, Object data) {
        return new ApiResponse("SUCCESS", message, data);
    }

    public static ApiResponse error(String message) {
        return new ApiResponse("ERROR", message);
    }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }
}
