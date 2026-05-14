package com.example.handyhirebackend.job.repository;

import com.example.handyhirebackend.job.model.Bid;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BidRepository extends JpaRepository<Bid, Long> {
    List<Bid> findByJobId(Long jobId);
    List<Bid> findByProviderId(Long providerId);
    List<Bid> findByJobIdAndStatus(Long jobId, String status);
}
