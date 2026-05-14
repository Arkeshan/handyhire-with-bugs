package com.example.handyhirebackend.booking.repository;

import com.example.handyhirebackend.booking.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    Optional<Booking> findByJobId(Long jobId);
    List<Booking> findByCustomerId(Long customerId);
    List<Booking> findByProviderId(Long providerId);
    List<Booking> findByStatus(String status);
}
