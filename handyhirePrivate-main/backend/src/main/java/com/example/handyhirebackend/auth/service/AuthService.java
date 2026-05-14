package com.example.handyhirebackend.auth.service;

import com.example.handyhirebackend.auth.model.*;
import com.example.handyhirebackend.auth.repository.UserRepository;
import com.example.handyhirebackend.common.exception.BadRequestException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@Service
public class AuthService {

    @Autowired private UserRepository userRepository;

    public LoginResponse login(LoginRequest request) {
        Optional<User> opt = userRepository.findByEmail(request.getEmail());

        if (opt.isEmpty()) {
            return new LoginResponse("INVALID_CREDENTIALS", null, "Invalid email or password");
        }

        User user = opt.get();

        if (!user.getPassword().equals(request.getPassword())) {
            return new LoginResponse("INVALID_CREDENTIALS", null, "Invalid email or password");
        }

        Set<String> roles = user.getRoles();

        // 1. ADDED: Check verification for EVERYONE (except the Admin) right after password check
        if (!user.isVerified() && roles.contains("PROVIDER")) {
            return new LoginResponse("PENDING_VERIFICATION", null, "Account pending admin approval", user.getId());
        }

        if (roles.contains("ADMIN")) {
            return new LoginResponse("OTP_REQUIRED", null, "Admin login requires OTP", user.getId());
        }

        if (roles.contains("CUSTOMER") && roles.contains("PROVIDER")) {
            return new LoginResponse("CHOOSE_ROLE", null, "Choose login as CUSTOMER or PROVIDER", user.getId());
        }

        if (roles.contains("PROVIDER")) {
            // REMOVED the old provider-only verification check from here
            return new LoginResponse("SUCCESS", "PROVIDER", "Login successful", user.getId());
        }

        if (roles.contains("CUSTOMER")) {
            return new LoginResponse("SUCCESS", "CUSTOMER", "Login successful", user.getId());
        }

        return new LoginResponse("FAILED", null, "No valid role assigned");
    }

    public LoginResponse register(RegisterRequest request) {
        if (isBlank(request.getName()) || isBlank(request.getEmail()) ||
                isBlank(request.getPassword()) || isBlank(request.getRole())) {
            throw new BadRequestException("Name, email, password and role are required");
        }

        String normalizedRole = request.getRole().toUpperCase();
        Optional<User> opt = userRepository.findByEmail(request.getEmail());

        // ... existing "if user already exists" block remains unchanged ...
        if (opt.isPresent()) {
            User existing = opt.get();
            if (!existing.getPassword().equals(request.getPassword())) {
                return new LoginResponse("FAILED", null, "Email already exists with a different password");
            }
            if (existing.getRoles().contains(normalizedRole)) {
                return new LoginResponse("FAILED", null, "User already registered as " + normalizedRole);
            }
// ADDED: If an existing CUSTOMER upgrades to a PROVIDER, save their uploaded images!
            if ("PROVIDER".equals(normalizedRole)) {
                existing.setIdProofName(request.getIdProofName());
                existing.setCertificationName(request.getCertificationName());
                existing.setVerified(false); // Send them to the admin for approval
            }
            existing.getRoles().add(normalizedRole);
            userRepository.save(existing);
            return new LoginResponse("SUCCESS", normalizedRole, "New role added successfully", existing.getId());
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
// Inside your register method, right below where you set the Name, Email, Password, and Phone:
        user.setPhone(request.getPhone());
        
        // ADD THESE TWO LINES:
        user.setProfession(request.getProfession());
        user.setExperience(request.getExperience());
// ---> ADD THESE TWO LINES to save the images for new users! <---
        user.setIdProofName(request.getIdProofName());
        user.setCertificationName(request.getCertificationName());
        // 2. UPDATED: Set verified to FALSE for every new user automatically
// 2. UPDATED: Auto-verify customers, require manual verification for providers
        if ("CUSTOMER".equals(normalizedRole)) {
            user.setVerified(true);
        } else {
            user.setVerified(false); 
        }
        Set<String> roles = new HashSet<>();
        roles.add(normalizedRole);
        user.setRoles(roles);

        User saved = userRepository.save(user);
        
        // 3. UPDATED: Generic pending message for everyone
 // 3. UPDATED: Specific message based on role
        String msg;
        if ("CUSTOMER".equals(normalizedRole)) {
            msg = "Registration successful.";
        } else {
            msg = "Registration successful. Pending admin verification.";
        }

        return new LoginResponse("SUCCESS", normalizedRole, msg, saved.getId());
    }
    
    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
