package com.example.handyhirebackend.auth.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
// Paste these alongside your other @Column variables (like phone, email, etc.)
    @Column(name = "id_proof_name", length = 1000)
    private String idProofName;

    @Column(name = "certification_name", length = 1000)
    private String certificationName;

    // Paste these Getters and Setters at the bottom of the file
    public String getIdProofName() { return idProofName; }
    public void setIdProofName(String idProofName) { this.idProofName = idProofName; }

    public String getCertificationName() { return certificationName; }
    public void setCertificationName(String certificationName) { this.certificationName = certificationName; }
    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    private String phone;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<String> roles = new HashSet<>();

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "is_verified")
    private boolean isVerified = false;
@Column(name = "profession")
    private String profession;

    @Column(name = "experience")
    private Integer experience;

    // Add Getters and Setters at the bottom:
    public String getProfession() { return profession; }
    public void setProfession(String profession) { this.profession = profession; }
    
    public Integer getExperience() { return experience; }
    public void setExperience(Integer experience) { this.experience = experience; }
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public User() {}

    public User(String name, String email, String password, Set<String> roles) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.roles = roles;
    }

    // --- Getters and Setters ---
    public Long getId() { return id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public Set<String> getRoles() { return roles; }
    public void setRoles(Set<String> roles) { this.roles = roles; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public boolean isVerified() { return isVerified; }
    public void setVerified(boolean verified) { isVerified = verified; }
}
