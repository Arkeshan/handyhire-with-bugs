package com.example.handyhirebackend.admin.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "disputes")
public class Dispute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "job_id", nullable = false)
    private Long jobId;

    @Column(name = "raised_by_user_id", nullable = false)
    private Long raisedByUserId;

    @Column(name = "raised_against_user_id", nullable = false)
    private Long raisedAgainstUserId;

    private String reason;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String status; // OPEN, UNDER_REVIEW, RESOLVED, DISMISSED

    @Column(name = "admin_notes", columnDefinition = "TEXT")
    private String adminNotes;

    @Column(name = "resolution")
    private String resolution;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.status == null) this.status = "OPEN";
    }

    // --- Getters and Setters ---
    public Long getId() { return id; }
    public Long getJobId() { return jobId; }
    public void setJobId(Long jobId) { this.jobId = jobId; }
    public Long getRaisedByUserId() { return raisedByUserId; }
    public void setRaisedByUserId(Long raisedByUserId) { this.raisedByUserId = raisedByUserId; }
    public Long getRaisedAgainstUserId() { return raisedAgainstUserId; }
    public void setRaisedAgainstUserId(Long raisedAgainstUserId) { this.raisedAgainstUserId = raisedAgainstUserId; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminNotes() { return adminNotes; }
    public void setAdminNotes(String adminNotes) { this.adminNotes = adminNotes; }
    public String getResolution() { return resolution; }
    public void setResolution(String resolution) { this.resolution = resolution; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }
}
