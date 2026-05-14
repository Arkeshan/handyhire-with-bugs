package com.example.handyhirebackend.provider.service;

import com.example.handyhirebackend.common.exception.ResourceNotFoundException;
import com.example.handyhirebackend.provider.model.ProviderProfile;
import com.example.handyhirebackend.provider.repository.ProviderProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProviderService {

    @Autowired
    private ProviderProfileRepository profileRepository;

    public ProviderProfile createProfile(ProviderProfile profile) {
        return profileRepository.save(profile);
    }

    public ProviderProfile getProfileByUserId(Long userId) {
        return profileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Provider profile not found for user: " + userId));
    }

    public ProviderProfile getProfileById(Long id) {
        return profileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Provider profile not found: " + id));
    }

    public ProviderProfile updateProfile(Long userId, ProviderProfile updates) {
        ProviderProfile profile = getProfileByUserId(userId);
        if (updates.getProfession() != null) profile.setProfession(updates.getProfession());
        if (updates.getYearsOfExperience() != null) profile.setYearsOfExperience(updates.getYearsOfExperience());
        if (updates.getSkills() != null) profile.setSkills(updates.getSkills());
        if (updates.getLocation() != null) profile.setLocation(updates.getLocation());
        return profileRepository.save(profile);
    }

    public List<ProviderProfile> getProvidersByProfession(String profession) {
        return profileRepository.findByVerificationStatusAndProfession("APPROVED", profession);
    }

    public List<ProviderProfile> getAvailableProviders() {
        return profileRepository.findByVerificationStatus("APPROVED");
    }

    public List<ProviderProfile> getPendingProviders() {
        return profileRepository.findByVerificationStatus("PENDING");
    }

    public ProviderProfile updateRating(Long userId, Double newRating) {
        ProviderProfile profile = getProfileByUserId(userId);
        int totalJobs = profile.getTotalJobsCompleted();
        double currentAvg = profile.getAverageRating();
        double updatedAvg = ((currentAvg * totalJobs) + newRating) / (totalJobs + 1);
        profile.setAverageRating(Math.round(updatedAvg * 10.0) / 10.0);
        profile.setTotalJobsCompleted(totalJobs + 1);
        return profileRepository.save(profile);
    }
}
