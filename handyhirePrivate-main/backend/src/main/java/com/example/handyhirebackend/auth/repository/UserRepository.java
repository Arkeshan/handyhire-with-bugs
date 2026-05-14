package com.example.handyhirebackend.auth.repository;

import com.example.handyhirebackend.auth.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query; // IMPORT ADDED

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByRolesContaining(String role);
    
    // 1. ADDED: Custom query bypassing Spring's naming conventions
    @Query("SELECT u FROM User u WHERE u.isVerified = false")
    List<User> findPendingUsers(); 
}