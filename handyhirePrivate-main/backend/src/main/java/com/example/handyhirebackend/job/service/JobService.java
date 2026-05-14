package com.example.handyhirebackend.job.service;

import com.example.handyhirebackend.common.exception.BadRequestException;
import com.example.handyhirebackend.common.exception.ResourceNotFoundException;
import com.example.handyhirebackend.job.model.Bid;
import com.example.handyhirebackend.job.model.Job;
import com.example.handyhirebackend.job.repository.BidRepository;
import com.example.handyhirebackend.job.repository.JobRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class JobService {

    @Autowired private JobRepository jobRepository;
    @Autowired private BidRepository bidRepository;

    // ─── Job CRUD ─────────────────────────────────────────────────────────────

    public Job createJob(Job job) {
        job.setStatus("OPEN");
        return jobRepository.save(job);
    }

    public Job getJobById(Long id) {
        return jobRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Job not found: " + id));
    }

    public List<Job> getAllJobs()                         { return jobRepository.findAll(); }
    public List<Job> getJobsByCustomer(Long customerId)  { return jobRepository.findByCustomerId(customerId); }
    public List<Job> getJobsByProvider(Long providerId)  { return jobRepository.findByProviderId(providerId); }
    public List<Job> getJobsByStatus(String status)      { return jobRepository.findByStatus(status); }
    public List<Job> getJobsByCategory(String category)  { return jobRepository.findByCategory(category); }

    /** "Open" means OPEN status — what the frontend's /api/jobs/open hits */
    public List<Job> getOpenJobs() {
        return jobRepository.findByStatus("OPEN");
    }

    public List<Job> getOngoingJobs() {
        return jobRepository.findByStatusIn(List.of("ASSIGNED", "IN_PROGRESS"));
    }
    public List<Job> getOpenJobsByCategory(String category) {
        return jobRepository.findByStatusAndCategory("OPEN", category);
    }
    // ─── Lifecycle ────────────────────────────────────────────────────────────

    public Job assignProvider(Long jobId, Long providerId, Double agreedPrice) {
        Job job = getJobById(jobId);
        job.setProviderId(providerId);
        job.setAgreedPrice(agreedPrice);
        job.setStatus("ASSIGNED");
        return jobRepository.save(job);
    }

    public Job startJob(Long jobId) {
        Job job = getJobById(jobId);
        if (!"ASSIGNED".equals(job.getStatus()))
            throw new BadRequestException("Job must be ASSIGNED before starting");
        job.setStatus("IN_PROGRESS");
        return jobRepository.save(job);
    }

    public Job completeJob(Long jobId) {
        Job job = getJobById(jobId);
        job.setStatus("COMPLETED");
        job.setCompletedAt(LocalDateTime.now());
        return jobRepository.save(job);
    }

    public Job cancelJob(Long jobId) {
        Job job = getJobById(jobId);
        if ("COMPLETED".equals(job.getStatus()))
            throw new BadRequestException("Cannot cancel a completed job");
        job.setStatus("CANCELLED");
        return jobRepository.save(job);
    }

    public Job disputeJob(Long jobId) {
        Job job = getJobById(jobId);
        job.setStatus("DISPUTED");
        return jobRepository.save(job);
    }

    // ─── Bidding ──────────────────────────────────────────────────────────────

    public Bid placeBid(Bid bid) {
        Job job = getJobById(bid.getJobId());
        if (!"OPEN".equals(job.getStatus()))
            throw new BadRequestException("Job is not open for bidding");
        bid.setStatus("PENDING");
        return bidRepository.save(bid);
    }

    public List<Bid> getBidsByJob(Long jobId) { return bidRepository.findByJobId(jobId); }

    public Bid acceptBid(Long bidId) {
        Bid bid = bidRepository.findById(bidId)
                .orElseThrow(() -> new ResourceNotFoundException("Bid not found: " + bidId));
        bid.setStatus("ACCEPTED");
        bidRepository.save(bid);

        // Reject all other bids for this job
        bidRepository.findByJobId(bid.getJobId()).stream()
                .filter(b -> !b.getId().equals(bidId))
                .forEach(b -> { b.setStatus("REJECTED"); bidRepository.save(b); });

        assignProvider(bid.getJobId(), bid.getProviderId(), bid.getAmount());
        return bid;
    }

    public Bid rejectBid(Long bidId) {
        Bid bid = bidRepository.findById(bidId)
                .orElseThrow(() -> new ResourceNotFoundException("Bid not found: " + bidId));
        bid.setStatus("REJECTED");
        return bidRepository.save(bid);
    }

    public Bid counterBid(Long bidId, Double newAmount, String message) {
        Bid original = bidRepository.findById(bidId)
                .orElseThrow(() -> new ResourceNotFoundException("Bid not found: " + bidId));
        original.setStatus("COUNTERED");
        bidRepository.save(original);

        Bid counter = new Bid();
        counter.setJobId(original.getJobId());
        counter.setProviderId(original.getProviderId());
        counter.setAmount(newAmount);
        counter.setMessage(message);
        counter.setStatus("PENDING");
        return bidRepository.save(counter);
    }
}
