package com.example.handyhirebackend.admin.repository;

import com.example.handyhirebackend.admin.model.Dispute;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DisputeRepository extends JpaRepository<Dispute, Long> {
    List<Dispute> findByStatus(String status);
    List<Dispute> findByJobId(Long jobId);
    List<Dispute> findByRaisedByUserId(Long userId);
}
