package com.example.handyhirebackend.job.repository;

import com.example.handyhirebackend.job.model.Job;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface JobRepository extends JpaRepository<Job, Long> {
    List<Job> findByCustomerId(Long customerId);
    List<Job> findByProviderId(Long providerId);
    List<Job> findByStatus(String status);
    List<Job> findByCategory(String category);
    List<Job> findByProviderIdAndStatus(Long providerId, String status);
    List<Job> findByCustomerIdAndStatus(Long customerId, String status);
    List<Job> findByStatusIn(List<String> statuses);
    List<Job> findByStatusAndCategory(String status, String category);
}
