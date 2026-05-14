package com.example.handyhirebackend.provider.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "provider_profiles")
public class ProviderProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    private String profession;

    @Column(name = "years_of_experience")
    private Integer yearsOfExperience;

    private String skills;
    private String location;

    @Column(name = "nic_document_url")
    private String nicDocumentUrl;

    @Column(name = "certificate_url")
    private String certificateUrl;

    @Column(name = "verification_status")
    private String verificationStatus; // PENDING, APPROVED, REJECTED

    @Column(name = "average_rating")
    private Double averageRating = 0.0;

    @Column(name = "total_jobs_completed")
    private Integer totalJobsCompleted = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.verificationStatus == null) this.verificationStatus = "PENDING";
    }

    // --- Getters and Setters ---
    public Long getId() { return id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getProfession() { return profession; }
    public void setProfession(String profession) { this.profession = profession; }
    public Integer getYearsOfExperience() { return yearsOfExperience; }
    public void setYearsOfExperience(Integer yearsOfExperience) { this.yearsOfExperience = yearsOfExperience; }
    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getNicDocumentUrl() { return nicDocumentUrl; }
    public void setNicDocumentUrl(String nicDocumentUrl) { this.nicDocumentUrl = nicDocumentUrl; }
    public String getCertificateUrl() { return certificateUrl; }
    public void setCertificateUrl(String certificateUrl) { this.certificateUrl = certificateUrl; }
    public String getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(String verificationStatus) { this.verificationStatus = verificationStatus; }
    public Double getAverageRating() { return averageRating; }
    public void setAverageRating(Double averageRating) { this.averageRating = averageRating; }
    public Integer getTotalJobsCompleted() { return totalJobsCompleted; }
    public void setTotalJobsCompleted(Integer totalJobsCompleted) { this.totalJobsCompleted = totalJobsCompleted; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
