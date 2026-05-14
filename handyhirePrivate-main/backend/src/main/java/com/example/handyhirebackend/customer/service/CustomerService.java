package com.example.handyhirebackend.customer.service;

import com.example.handyhirebackend.common.exception.BadRequestException;
import com.example.handyhirebackend.common.exception.ResourceNotFoundException;
import com.example.handyhirebackend.customer.model.Review;
import com.example.handyhirebackend.customer.repository.ReviewRepository;
import com.example.handyhirebackend.provider.service.ProviderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerService {

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private ProviderService providerService;

    public Review submitReview(Review review) {
        if (review.getRating() < 1 || review.getRating() > 5) {
            throw new BadRequestException("Rating must be between 1 and 5");
        }
        if (reviewRepository.existsByJobId(review.getJobId())) {
            throw new BadRequestException("Review already submitted for this job");
        }
        Review saved = reviewRepository.save(review);

        // Update provider's average rating
        providerService.updateRating(review.getProviderId(), review.getRating().doubleValue());

        return saved;
    }

    public List<Review> getReviewsForProvider(Long providerId) {
        return reviewRepository.findByProviderId(providerId);
    }

    public List<Review> getReviewsByCustomer(Long customerId) {
        return reviewRepository.findByCustomerId(customerId);
    }

    public Review getReviewByJob(Long jobId) {
        return reviewRepository.findByJobId(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("No review found for job: " + jobId));
    }
}
