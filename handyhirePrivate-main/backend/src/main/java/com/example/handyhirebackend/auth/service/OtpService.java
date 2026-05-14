package com.example.handyhirebackend.auth.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OtpService {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${spring.mail.username:not-configured}")
    private String fromEmail;

    // In-memory OTP store
    private final Map<String, String> otpStore = new ConcurrentHashMap<>();
    private final Random random = new Random();

    public String generateOtp(String email) {
        String otp = String.format("%06d", 100000 + random.nextInt(900000));
        otpStore.put(email, otp);

        // Always print to console so you have a fallback if email fails
        System.out.println("\n========================================");
        System.out.println("  OTP for " + email + " : " + otp);
        System.out.println("========================================\n");

        // Try to send email
        if (mailSender != null && !fromEmail.equals("not-configured")) {
            try {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setFrom(fromEmail);
                message.setTo(email);
                message.setSubject("HandyHire Admin OTP");
                message.setText(
                    "Your HandyHire admin OTP is: " + otp + "\n\n" +
                    "This code expires in 10 minutes.\n\n" +
                    "If you did not request this, ignore this email."
                );
                mailSender.send(message);
                System.out.println("  ✓ OTP email sent to " + email);
            } catch (Exception e) {
                System.out.println("  ⚠ Could not send email: " + e.getMessage());
                System.out.println("  → Use the OTP printed above in the console instead.");
            }
        } else {
            System.out.println("  ℹ Email not configured — use the OTP above.");
        }

        return otp;
    }

    public boolean verifyOtp(String email, String otp) {
        String stored = otpStore.get(email);
        if (stored != null && stored.equals(otp)) {
            otpStore.remove(email);
            return true;
        }
        return false;
    }
}
