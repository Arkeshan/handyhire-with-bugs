package com.example.handyhirebackend.provider.controller;

import com.example.handyhirebackend.provider.model.ProviderProfile;
import com.example.handyhirebackend.provider.service.ProviderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/providers")
public class ProviderController {

    @Autowired
    private ProviderService providerService;

    @PostMapping
    public ResponseEntity<ProviderProfile> createProfile(@RequestBody ProviderProfile profile) {
        return ResponseEntity.ok(providerService.createProfile(profile));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ProviderProfile> getProfileByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(providerService.getProfileByUserId(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProviderProfile> getProfileById(@PathVariable Long id) {
        return ResponseEntity.ok(providerService.getProfileById(id));
    }

    @PutMapping("/user/{userId}")
    public ResponseEntity<ProviderProfile> updateProfile(
            @PathVariable Long userId,
            @RequestBody ProviderProfile updates) {
        return ResponseEntity.ok(providerService.updateProfile(userId, updates));
    }

    @GetMapping("/profession/{profession}")
    public ResponseEntity<List<ProviderProfile>> getByProfession(@PathVariable String profession) {
        return ResponseEntity.ok(providerService.getProvidersByProfession(profession));
    }

    @GetMapping("/available")
    public ResponseEntity<List<ProviderProfile>> getAvailable() {
        return ResponseEntity.ok(providerService.getAvailableProviders());
    }
}
