package com.example.handyhirebackend.job.controller;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import com.example.handyhirebackend.job.model.Bid;
import com.example.handyhirebackend.job.model.Job;
import com.example.handyhirebackend.job.service.JobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/jobs")
public class JobController {

    @Autowired
    private JobService jobService;
    @Autowired private SimpMessagingTemplate messagingTemplate;

    // ──── Job CRUD ────────────────────────────────────────────────────────────

    @PostMapping
    public ResponseEntity<Job> createJob(
            @RequestBody Job job,
            @RequestParam Long customerId) {
        job.setCustomerId(customerId);
        Job savedJob = jobService.createJob(job);
        messagingTemplate.convertAndSend("/topic/jobs" + savedJob.getCategory(), savedJob);
        return ResponseEntity.ok(savedJob);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Job> getById(@PathVariable Long id) {
        return ResponseEntity.ok(jobService.getJobById(id));
    }

    @GetMapping
    public ResponseEntity<List<Job>> getAll() {
        return ResponseEntity.ok(jobService.getAllJobs());
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Job>> getByCustomer(@PathVariable Long customerId) {
        return ResponseEntity.ok(jobService.getJobsByCustomer(customerId));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<Job>> getByProvider(@PathVariable Long providerId) {
        return ResponseEntity.ok(jobService.getJobsByProvider(providerId));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Job>> getByStatus(@PathVariable String status) {
        return ResponseEntity.ok(jobService.getJobsByStatus(status));
    }

    /**
     * GET /api/jobs/open
     * GET /api/jobs/open?category=Plumbing
     * Used by the provider side to fetch jobs matching their skill.
     */
    @GetMapping("/open")
    public ResponseEntity<List<Job>> getOpenJobs(
            @RequestParam(required = false) String category) {
        if (category != null && !category.isBlank()) {
            return ResponseEntity.ok(jobService.getOpenJobsByCategory(category));
        }
        return ResponseEntity.ok(jobService.getOpenJobs());
    }

    @GetMapping("/ongoing")
    public ResponseEntity<List<Job>> getOngoing() {
        return ResponseEntity.ok(jobService.getOngoingJobs());
    }

    // ──── Lifecycle ───────────────────────────────────────────────────────────

    @PutMapping("/{jobId}/assign")
    public ResponseEntity<Job> assignProvider(
            @PathVariable Long jobId,
            @RequestBody Map<String, Object> body) {
        Long providerId = Long.valueOf(body.get("providerId").toString());
        Double agreedPrice = Double.valueOf(body.get("agreedPrice").toString());
        return ResponseEntity.ok(jobService.assignProvider(jobId, providerId, agreedPrice));
    }

    @PutMapping("/{jobId}/start")
    public ResponseEntity<Job> startJob(@PathVariable Long jobId) {
        return ResponseEntity.ok(jobService.startJob(jobId));
    }

    @PutMapping("/{jobId}/complete")
    public ResponseEntity<Job> completeJob(@PathVariable Long jobId) {
        return ResponseEntity.ok(jobService.completeJob(jobId));
    }

    @PutMapping("/{jobId}/cancel")
    public ResponseEntity<Job> cancelJob(@PathVariable Long jobId) {
        return ResponseEntity.ok(jobService.cancelJob(jobId));
    }

    @PutMapping("/{jobId}/dispute")
    public ResponseEntity<Job> disputeJob(@PathVariable Long jobId) {
        return ResponseEntity.ok(jobService.disputeJob(jobId));
    }

    // ──── Bidding ─────────────────────────────────────────────────────────────

    @PostMapping("/{jobId}/bids")
    public ResponseEntity<Bid> placeBid(
            @PathVariable Long jobId,
            @RequestBody Bid bid) {
        bid.setJobId(jobId);
        return ResponseEntity.ok(jobService.placeBid(bid));
    }

    @GetMapping("/{jobId}/bids")
    public ResponseEntity<List<Bid>> getBids(@PathVariable Long jobId) {
        return ResponseEntity.ok(jobService.getBidsByJob(jobId));
    }

    @PutMapping("/{jobId}/bids/{bidId}/accept")
    public ResponseEntity<Bid> acceptBid(
            @PathVariable Long jobId,
            @PathVariable Long bidId) {
        return ResponseEntity.ok(jobService.acceptBid(bidId));
    }

    @PutMapping("/{jobId}/bids/{bidId}/reject")
    public ResponseEntity<Bid> rejectBid(
            @PathVariable Long jobId,
            @PathVariable Long bidId) {
        return ResponseEntity.ok(jobService.rejectBid(bidId));
    }

    @PutMapping("/{jobId}/bids/{bidId}/counter-offer")
    public ResponseEntity<Bid> counterOffer(
            @PathVariable Long jobId,
            @PathVariable Long bidId,
            @RequestBody Map<String, Object> body) {
        Double newAmount = Double.valueOf(body.get("amount").toString());
        String message = body.getOrDefault("message", "").toString();
        return ResponseEntity.ok(jobService.counterBid(bidId, newAmount, message));
    }

    // ──── History (used by provider Job History screen) ───────────────────────

    @GetMapping("/history/{providerId}")
    public ResponseEntity<List<Job>> getHistory(@PathVariable Long providerId) {
        return ResponseEntity.ok(jobService.getJobsByProvider(providerId));
    }
}
