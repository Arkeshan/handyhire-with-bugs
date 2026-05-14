package com.example.handyhirebackend.customer.controller;

import com.example.handyhirebackend.customer.model.Review;
import com.example.handyhirebackend.customer.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {

    @Autowired
    private CustomerService customerService;

    // ──── Reviews ────

    @PostMapping("/reviews")
    public ResponseEntity<Review> submitReview(@RequestBody Review review) {
        return ResponseEntity.ok(customerService.submitReview(review));
    }

    @GetMapping("/reviews/provider/{providerId}")
    public ResponseEntity<List<Review>> getProviderReviews(@PathVariable Long providerId) {
        return ResponseEntity.ok(customerService.getReviewsForProvider(providerId));
    }

    @GetMapping("/reviews/customer/{customerId}")
    public ResponseEntity<List<Review>> getCustomerReviews(@PathVariable Long customerId) {
        return ResponseEntity.ok(customerService.getReviewsByCustomer(customerId));
    }

    @GetMapping("/reviews/job/{jobId}")
    public ResponseEntity<Review> getJobReview(@PathVariable Long jobId) {
        return ResponseEntity.ok(customerService.getReviewByJob(jobId));
    }
}
