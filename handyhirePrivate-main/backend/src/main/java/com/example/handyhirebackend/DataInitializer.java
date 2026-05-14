package com.example.handyhirebackend;

import com.example.handyhirebackend.auth.model.User;
import com.example.handyhirebackend.auth.repository.UserRepository;
import com.example.handyhirebackend.provider.model.ProviderProfile;
import com.example.handyhirebackend.provider.repository.ProviderProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Set;

/**
 * Seeds the H2 database with test accounts on startup.
 *
 * Admin email is set to arkesuje@gmail.com so the real OTP
 * email lands in that inbox.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired private UserRepository userRepository;
    @Autowired private ProviderProfileRepository providerProfileRepository;

    @Override
    public void run(String... args) {

        // ── Admin (your real Gmail) ────────────────────────────────────────
        if (!userRepository.existsByEmail("arkesuje@gmail.com")) {
            User admin = new User();
            admin.setName("Admin");
            admin.setEmail("arkesuje@gmail.com");
            admin.setPassword("admin123");
            admin.setRoles(Set.of("ADMIN"));
            admin.setVerified(true);
            userRepository.save(admin);
        }

        // ── Test Customer ─────────────────────────────────────────────────
        if (!userRepository.existsByEmail("customer@test.com")) {
            User customer = new User();
            customer.setName("Alex Johnson");
            customer.setEmail("customer@test.com");
            customer.setPassword("test123");
            customer.setRoles(Set.of("CUSTOMER"));
            customer.setVerified(true);
            userRepository.save(customer);
        }

        // ── Test Provider (pre-approved) ──────────────────────────────────
        if (!userRepository.existsByEmail("provider@test.com")) {
            User provider = new User();
            provider.setName("Kasun Perera");
            provider.setEmail("provider@test.com");
            provider.setPassword("test123");
            provider.setRoles(Set.of("PROVIDER"));
            provider.setVerified(true);
            User saved = userRepository.save(provider);

            ProviderProfile profile = new ProviderProfile();
            profile.setUserId(saved.getId());
            profile.setProfession("Plumbing");
            profile.setYearsOfExperience(5);
            profile.setSkills("Plumbing, Pipe Repair, Installation");
            profile.setLocation("Colombo");
            profile.setVerificationStatus("APPROVED");
            profile.setAverageRating(4.7);
            profile.setTotalJobsCompleted(42);
            providerProfileRepository.save(profile);
        }

        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        System.out.println("  HandyHire backend running on http://localhost:8080");
        System.out.println("  H2 console: http://localhost:8080/h2-console");
        System.out.println();
        System.out.println("  Demo accounts:");
        System.out.println("    Admin   : arkesuje@gmail.com / admin123");
        System.out.println("    Customer: customer@test.com  / test123");
        System.out.println("    Provider: provider@test.com  / test123");
        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    }
}
