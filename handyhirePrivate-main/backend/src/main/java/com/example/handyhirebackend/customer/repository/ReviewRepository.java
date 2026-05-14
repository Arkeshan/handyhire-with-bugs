package com.example.handyhirebackend.customer.repository;

import com.example.handyhirebackend.customer.model.Review;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByProviderId(Long providerId);
    List<Review> findByCustomerId(Long customerId);
    Optional<Review> findByJobId(Long jobId);
    boolean existsByJobId(Long jobId);
}
