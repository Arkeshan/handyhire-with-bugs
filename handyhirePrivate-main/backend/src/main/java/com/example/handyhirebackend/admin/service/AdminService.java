package com.example.handyhirebackend.admin.service;

import com.example.handyhirebackend.admin.model.Dispute;
import com.example.handyhirebackend.admin.repository.DisputeRepository;
import com.example.handyhirebackend.auth.model.User;
import com.example.handyhirebackend.auth.repository.UserRepository;
import com.example.handyhirebackend.common.exception.ResourceNotFoundException;
import com.example.handyhirebackend.job.model.Job;
import com.example.handyhirebackend.job.repository.JobRepository;
import com.example.handyhirebackend.provider.model.ProviderProfile;
import com.example.handyhirebackend.provider.repository.ProviderProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AdminService {

    @Autowired
    private ProviderProfileRepository providerProfileRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private DisputeRepository disputeRepository;

    // ──── Provider Verification ────

    public List<ProviderProfile> getPendingVerifications() {
        return providerProfileRepository.findByVerificationStatus("PENDING");
    }

    public ProviderProfile approveProvider(Long profileId) {
        ProviderProfile profile = providerProfileRepository.findById(profileId)
                .orElseThrow(() -> new ResourceNotFoundException("Provider profile not found"));
        profile.setVerificationStatus("APPROVED");
        providerProfileRepository.save(profile);

        // Also mark user as verified
        User user = userRepository.findById(profile.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setVerified(true);
        userRepository.save(user);

        return profile;
    }

    public ProviderProfile rejectProvider(Long profileId) {
        ProviderProfile profile = providerProfileRepository.findById(profileId)
                .orElseThrow(() -> new ResourceNotFoundException("Provider profile not found"));
        profile.setVerificationStatus("REJECTED");
        return providerProfileRepository.save(profile);
    }

    // ──── Job Monitoring ────

    public List<Job> getOngoingJobs() {
        return jobRepository.findByStatusIn(List.of("ASSIGNED", "IN_PROGRESS"));
    }

    public Job terminateJob(Long jobId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job not found"));
        job.setStatus("CANCELLED");
        return jobRepository.save(job);
    }

    // ──── Disputes ────

    public Dispute createDispute(Dispute dispute) {
        return disputeRepository.save(dispute);
    }

    public List<Dispute> getAllDisputes() {
        return disputeRepository.findAll();
    }

    public List<Dispute> getDisputesByStatus(String status) {
        return disputeRepository.findByStatus(status);
    }

    public Dispute resolveDispute(Long disputeId, String resolution, String adminNotes) {
        Dispute dispute = disputeRepository.findById(disputeId)
                .orElseThrow(() -> new ResourceNotFoundException("Dispute not found"));
        dispute.setStatus("RESOLVED");
        dispute.setResolution(resolution);
        dispute.setAdminNotes(adminNotes);
        dispute.setResolvedAt(LocalDateTime.now());
        return disputeRepository.save(dispute);
    }

    public Dispute dismissDispute(Long disputeId, String adminNotes) {
        Dispute dispute = disputeRepository.findById(disputeId)
                .orElseThrow(() -> new ResourceNotFoundException("Dispute not found"));
        dispute.setStatus("DISMISSED");
        dispute.setAdminNotes(adminNotes);
        dispute.setResolvedAt(LocalDateTime.now());
        return disputeRepository.save(dispute);
    }

    // ──── User Verification Methods ────

    public List<User> getUnverifiedUsers() {
        // Exclude admins from the pending list just in case
        return userRepository.findPendingUsers().stream()
            .filter(u -> !u.getRoles().contains("ADMIN"))
            .toList();
    }

    public User approveUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setVerified(true);
        return userRepository.save(user);
    }

    public void rejectUser(Long userId) {
        // Find the user first to ensure they exist
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

        // COMPLETELY delete the user so they can reuse their email to try again
        userRepository.delete(user);
        
        System.out.println("User " + user.getEmail() + " has been rejected and deleted.");
    }

    // ──── Dashboard ────

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", userRepository.count());
        stats.put("totalJobs", jobRepository.count());
        stats.put("ongoingJobs", jobRepository.findByStatusIn(List.of("ASSIGNED", "IN_PROGRESS")).size());
        stats.put("openDisputes", disputeRepository.findByStatus("OPEN").size());
        stats.put("pendingVerifications", providerProfileRepository.findByVerificationStatus("PENDING").size());
        stats.put("totalProviders", userRepository.findByRolesContaining("PROVIDER").size());
        stats.put("totalCustomers", userRepository.findByRolesContaining("CUSTOMER").size());
        return stats;
    }
}