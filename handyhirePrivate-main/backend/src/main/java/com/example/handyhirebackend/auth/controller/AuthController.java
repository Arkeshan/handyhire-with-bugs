package com.example.handyhirebackend.auth.controller;

import com.example.handyhirebackend.auth.model.LoginRequest;
import com.example.handyhirebackend.auth.model.LoginResponse;
import com.example.handyhirebackend.auth.model.RegisterRequest;
import com.example.handyhirebackend.auth.repository.UserRepository;
import com.example.handyhirebackend.auth.service.AuthService;
import com.example.handyhirebackend.auth.service.OtpService;
import com.example.handyhirebackend.common.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.handyhirebackend.auth.model.User;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired private AuthService authService;
    @Autowired private OtpService otpService;

    // ── Regular login ──────────────────────────────────────────────────────────
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse> logout() {
        // If you implement a token blacklist in the future, trigger it here.
        // Otherwise, simply return a successful response.
        return ResponseEntity.ok(ApiResponse.success("Successfully logged out"));
    }
    // ── Register ───────────────────────────────────────────────────────────────
    @PostMapping("/register")
    public ResponseEntity<LoginResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    // ── Admin OTP — send (frontend calls /api/auth/admin/send-otp) ────────────
    @PostMapping("/admin/send-otp")
    public ResponseEntity<ApiResponse> sendAdminOtp(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Email is required"));
        }
        otpService.generateOtp(email);
        return ResponseEntity.ok(ApiResponse.success("OTP sent to " + email +
                " (check server console during development)"));
    }

    // ── Admin OTP — verify (frontend calls /api/auth/admin/verify-otp) ────────
    @PostMapping("/admin/verify-otp")
    public ResponseEntity<ApiResponse> verifyAdminOtp(@RequestBody Map<String, Object> body) {
        String email = (String) body.get("email");
        // Frontend sends int otp, JSON deserializes it as Integer
        String otp = body.get("otp") != null ? body.get("otp").toString() : null;

        if (email == null || otp == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("email and otp are required"));
        }

        boolean valid = otpService.verifyOtp(email, otp);
        if (valid) {
            return ResponseEntity.ok(ApiResponse.success("OTP verified. Admin login successful."));
        }
        return ResponseEntity.badRequest().body(ApiResponse.error("Invalid or expired OTP"));
    }

    // ── Legacy paths kept for compatibility ───────────────────────────────────
    @PostMapping("/otp/send")
    public ResponseEntity<ApiResponse> sendOtpLegacy(@RequestBody Map<String, String> body) {
        return sendAdminOtp(body);
    }

    @PostMapping("/otp/verify")
    public ResponseEntity<ApiResponse> verifyOtpLegacy(@RequestBody Map<String, Object> body) {
        return verifyAdminOtp(body);
    }
    @Autowired
    private UserRepository userRepository; // Ensure this is available

    // Add this endpoint to fetch profile data by email
    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(@RequestParam String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Return the user object (Spring Boot will automatically convert it to JSON)
        return ResponseEntity.ok(user);
    }
}
