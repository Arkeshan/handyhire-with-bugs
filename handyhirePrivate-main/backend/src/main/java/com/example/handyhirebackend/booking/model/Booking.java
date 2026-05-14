package com.example.handyhirebackend.booking.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "job_id", nullable = false, unique = true)
    private Long jobId;

    @Column(name = "bid_id", nullable = false)
    private Long bidId;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "provider_id", nullable = false)
    private Long providerId;

    @Column(name = "agreed_price")
    private Double agreedPrice;

    /**
     * Lifecycle: CONFIRMED → ON_THE_WAY → REACHED → COMPLETED
     *            Any active state → CANCELLED
     */
    private String status;  // CONFIRMED, ON_THE_WAY, REACHED, COMPLETED, CANCELLED

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "arrived_at")
    private LocalDateTime arrivedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "provider_lat")
    private Double providerLat;

    @Column(name = "provider_lng")
    private Double providerLng;

    @Column(name = "cancellation_reason")
    private String cancellationReason;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.status == null) this.status = "CONFIRMED";
    }

    // ─── Getters / Setters ────────────────────────────────────────────────────
    public Long getId() { return id; }
    public Long getJobId() { return jobId; }
    public void setJobId(Long jobId) { this.jobId = jobId; }
    public Long getBidId() { return bidId; }
    public void setBidId(Long bidId) { this.bidId = bidId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getProviderId() { return providerId; }
    public void setProviderId(Long providerId) { this.providerId = providerId; }
    public Double getAgreedPrice() { return agreedPrice; }
    public void setAgreedPrice(Double agreedPrice) { this.agreedPrice = agreedPrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getStartedAt() { return startedAt; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }
    public LocalDateTime getArrivedAt() { return arrivedAt; }
    public void setArrivedAt(LocalDateTime arrivedAt) { this.arrivedAt = arrivedAt; }
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
    public Double getProviderLat() { return providerLat; }
    public void setProviderLat(Double providerLat) { this.providerLat = providerLat; }
    public Double getProviderLng() { return providerLng; }
    public void setProviderLng(Double providerLng) { this.providerLng = providerLng; }
    public String getCancellationReason() { return cancellationReason; }
    public void setCancellationReason(String cancellationReason) { this.cancellationReason = cancellationReason; }
}
