package com.example.handyhirebackend.booking.controller;

import com.example.handyhirebackend.booking.model.Booking;
import com.example.handyhirebackend.booking.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    @Autowired private BookingService bookingService;

    /**
     * POST /api/bookings?jobId=1&bidId=3
     * Called by the frontend when a customer confirms a provider.
     */
    @PostMapping
    public ResponseEntity<Booking> createBooking(
            @RequestParam Long jobId,
            @RequestParam Long bidId) {
        return ResponseEntity.ok(bookingService.createBooking(jobId, bidId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Booking> getById(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.getById(id));
    }

    @GetMapping("/job/{jobId}")
    public ResponseEntity<Booking> getByJob(@PathVariable Long jobId) {
        return ResponseEntity.ok(bookingService.getByJobId(jobId));
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Booking>> getByCustomer(@PathVariable Long customerId) {
        return ResponseEntity.ok(bookingService.getByCustomer(customerId));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<Booking>> getByProvider(@PathVariable Long providerId) {
        return ResponseEntity.ok(bookingService.getByProvider(providerId));
    }

    /**
     * PUT /api/bookings/{id}/start-journey
     * Body: { "lat": 6.9271, "lng": 79.8612 }
     */
    @PutMapping("/{id}/start-journey")
    public ResponseEntity<Booking> startJourney(
            @PathVariable Long id,
            @RequestBody Map<String, Double> body) {
        return ResponseEntity.ok(bookingService.startJourney(id,
                body.get("lat"), body.get("lng")));
    }

    /** PUT /api/bookings/{id}/arrived */
    @PutMapping("/{id}/arrived")
    public ResponseEntity<Booking> arrived(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.markArrived(id));
    }

    /** PUT /api/bookings/{id}/complete */
    @PutMapping("/{id}/complete")
    public ResponseEntity<Booking> complete(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.complete(id));
    }

    /** PUT /api/bookings/{id}/cancel   Body: { "reason": "..." } */
    @PutMapping("/{id}/cancel")
    public ResponseEntity<Booking> cancel(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body) {
        String reason = (body != null) ? body.getOrDefault("reason", "") : "";
        return ResponseEntity.ok(bookingService.cancel(id, reason));
    }

    /** PUT /api/bookings/{id}/location   Body: { "lat": ..., "lng": ... } */
    @PutMapping("/{id}/location")
    public ResponseEntity<Booking> updateLocation(
            @PathVariable Long id,
            @RequestBody Map<String, Double> body) {
        return ResponseEntity.ok(bookingService.updateLocation(id,
                body.get("lat"), body.get("lng")));
    }
}
