package com.example.handyhirebackend.provider.repository;

import com.example.handyhirebackend.provider.model.ProviderProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProviderProfileRepository extends JpaRepository<ProviderProfile, Long> {
    Optional<ProviderProfile> findByUserId(Long userId);
    List<ProviderProfile> findByVerificationStatus(String status);
    List<ProviderProfile> findByProfession(String profession);
    List<ProviderProfile> findByLocation(String location);
    List<ProviderProfile> findByVerificationStatusAndProfession(String status, String profession);
}
