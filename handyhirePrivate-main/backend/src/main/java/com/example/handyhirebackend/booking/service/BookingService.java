package com.example.handyhirebackend.booking.service;

import com.example.handyhirebackend.booking.model.Booking;
import com.example.handyhirebackend.booking.repository.BookingRepository;
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
public class BookingService {

    @Autowired private BookingRepository bookingRepository;
    @Autowired private JobRepository jobRepository;
    @Autowired private BidRepository bidRepository;

    /**
     * Creates a booking when a bid is accepted.
     * Called via POST /api/bookings?jobId=X&bidId=Y
     */
    public Booking createBooking(Long jobId, Long bidId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job not found: " + jobId));
        Bid bid = bidRepository.findById(bidId)
                .orElseThrow(() -> new ResourceNotFoundException("Bid not found: " + bidId));

        if (!"ACCEPTED".equals(bid.getStatus()) && !"PENDING".equals(bid.getStatus())) {
            throw new BadRequestException("Bid is not in an acceptable state");
        }

        // Auto-accept the bid if it's still PENDING
        if ("PENDING".equals(bid.getStatus())) {
            bid.setStatus("ACCEPTED");
            bidRepository.save(bid);
            job.setProviderId(bid.getProviderId());
            job.setAgreedPrice(bid.getAmount());
            job.setStatus("ASSIGNED");
            jobRepository.save(job);
        }

        Booking booking = new Booking();
        booking.setJobId(jobId);
        booking.setBidId(bidId);
        booking.setCustomerId(job.getCustomerId());
        booking.setProviderId(bid.getProviderId());
        booking.setAgreedPrice(bid.getAmount());
        booking.setStatus("CONFIRMED");

        return bookingRepository.save(booking);
    }

    public Booking getById(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + id));
    }

    public Booking getByJobId(Long jobId) {
        return bookingRepository.findByJobId(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("No booking for job: " + jobId));
    }

    public List<Booking> getByCustomer(Long customerId) {
        return bookingRepository.findByCustomerId(customerId);
    }

    public List<Booking> getByProvider(Long providerId) {
        return bookingRepository.findByProviderId(providerId);
    }

    /** PUT /api/bookings/{id}/start-journey  body: {lat, lng} */
    public Booking startJourney(Long bookingId, Double lat, Double lng) {
        Booking booking = getById(bookingId);
        if (!"CONFIRMED".equals(booking.getStatus()))
            throw new BadRequestException("Booking must be CONFIRMED to start journey");
        booking.setStatus("ON_THE_WAY");
        booking.setStartedAt(LocalDateTime.now());
        booking.setProviderLat(lat);
        booking.setProviderLng(lng);

        // Also update parent job
        updateJobStatus(booking.getJobId(), "IN_PROGRESS");

        return bookingRepository.save(booking);
    }

    /** PUT /api/bookings/{id}/arrived */
    public Booking markArrived(Long bookingId) {
        Booking booking = getById(bookingId);
        if (!"ON_THE_WAY".equals(booking.getStatus()))
            throw new BadRequestException("Provider must be ON_THE_WAY before arriving");
        booking.setStatus("REACHED");
        booking.setArrivedAt(LocalDateTime.now());
        return bookingRepository.save(booking);
    }

    /** PUT /api/bookings/{id}/complete */
    public Booking complete(Long bookingId) {
        Booking booking = getById(bookingId);
        booking.setStatus("COMPLETED");
        booking.setCompletedAt(LocalDateTime.now());
        updateJobStatus(booking.getJobId(), "COMPLETED");
        return bookingRepository.save(booking);
    }

    /** PUT /api/bookings/{id}/cancel  body: {reason} */
    public Booking cancel(Long bookingId, String reason) {
        Booking booking = getById(bookingId);
        if ("COMPLETED".equals(booking.getStatus()) || "CANCELLED".equals(booking.getStatus()))
            throw new BadRequestException("Cannot cancel a " + booking.getStatus() + " booking");
        booking.setStatus("CANCELLED");
        booking.setCancellationReason(reason);
        updateJobStatus(booking.getJobId(), "CANCELLED");
        return bookingRepository.save(booking);
    }

    /** PUT /api/bookings/{id}/location  body: {lat, lng} */
    public Booking updateLocation(Long bookingId, Double lat, Double lng) {
        Booking booking = getById(bookingId);
        booking.setProviderLat(lat);
        booking.setProviderLng(lng);
        return bookingRepository.save(booking);
    }

    private void updateJobStatus(Long jobId, String status) {
        jobRepository.findById(jobId).ifPresent(job -> {
            job.setStatus(status);
            if ("COMPLETED".equals(status)) job.setCompletedAt(LocalDateTime.now());
            jobRepository.save(job);
        });
    }
}
