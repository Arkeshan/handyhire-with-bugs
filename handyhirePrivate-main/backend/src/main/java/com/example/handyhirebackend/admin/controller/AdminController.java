package com.example.handyhirebackend.admin.controller;

import com.example.handyhirebackend.admin.model.Dispute;
import com.example.handyhirebackend.admin.service.AdminService;
import com.example.handyhirebackend.job.model.Job;
import com.example.handyhirebackend.provider.model.ProviderProfile;
import com.example.handyhirebackend.auth.model.User; // <--- ADD THIS LINE!

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    // ──── Dashboard ────

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard() {
        return ResponseEntity.ok(adminService.getDashboardStats());
    }

    // ──── Provider Verification ────
// ADD these endpoints to AdminController.java under Provider Verification

    @GetMapping("/users/pending")
    public ResponseEntity<List<User>> getPendingUsers() {
        return ResponseEntity.ok(adminService.getUnverifiedUsers());
    }

    @PutMapping("/users/{userId}/approve")
    public ResponseEntity<User> approveUser(@PathVariable Long userId) {
        return ResponseEntity.ok(adminService.approveUser(userId));
    }

    @DeleteMapping("/users/{userId}/reject")
    public ResponseEntity<Void> rejectUser(@PathVariable Long userId) {
        adminService.rejectUser(userId);
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/verifications/pending")
    public ResponseEntity<List<ProviderProfile>> getPendingVerifications() {
        return ResponseEntity.ok(adminService.getPendingVerifications());
    }

    @PutMapping("/verifications/{profileId}/approve")
    public ResponseEntity<ProviderProfile> approveProvider(@PathVariable Long profileId) {
        return ResponseEntity.ok(adminService.approveProvider(profileId));
    }

    @PutMapping("/verifications/{profileId}/reject")
    public ResponseEntity<ProviderProfile> rejectProvider(@PathVariable Long profileId) {
        return ResponseEntity.ok(adminService.rejectProvider(profileId));
    }

    // ──── Job Monitoring ────

    @GetMapping("/jobs/ongoing")
    public ResponseEntity<List<Job>> getOngoingJobs() {
        return ResponseEntity.ok(adminService.getOngoingJobs());
    }

    @PutMapping("/jobs/{jobId}/terminate")
    public ResponseEntity<Job> terminateJob(@PathVariable Long jobId) {
        return ResponseEntity.ok(adminService.terminateJob(jobId));
    }

    // ──── Disputes ────

    @PostMapping("/disputes")
    public ResponseEntity<Dispute> createDispute(@RequestBody Dispute dispute) {
        return ResponseEntity.ok(adminService.createDispute(dispute));
    }

    @GetMapping("/disputes")
    public ResponseEntity<List<Dispute>> getAllDisputes() {
        return ResponseEntity.ok(adminService.getAllDisputes());
    }

    @GetMapping("/disputes/status/{status}")
    public ResponseEntity<List<Dispute>> getDisputesByStatus(@PathVariable String status) {
        return ResponseEntity.ok(adminService.getDisputesByStatus(status));
    }

    @PutMapping("/disputes/{disputeId}/resolve")
    public ResponseEntity<Dispute> resolveDispute(
            @PathVariable Long disputeId,
            @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(adminService.resolveDispute(
                disputeId, body.get("resolution"), body.get("adminNotes")));
    }

    @PutMapping("/disputes/{disputeId}/dismiss")
    public ResponseEntity<Dispute> dismissDispute(
            @PathVariable Long disputeId,
            @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(adminService.dismissDispute(disputeId, body.get("adminNotes")));
    }
}
