package com.college.eventsbackend.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.college.eventsbackend.model.Admin;
import com.college.eventsbackend.model.AdminToken;
import com.college.eventsbackend.repository.AdminRepository;
import com.college.eventsbackend.repository.AdminTokenRepository;

@Service
public class AdminAuthService {

    private static final int TOKEN_VALID_HOURS = 12;

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private AdminTokenRepository adminTokenRepository;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final SecureRandom secureRandom = new SecureRandom();

    /**
     * Validates admin credentials and issues a new session token.
     * Returns null if credentials are invalid.
     */
    public AdminLoginResult login(String email, String rawPassword) {

        Optional<Admin> adminOpt = adminRepository.findByEmail(email);

        if (adminOpt.isEmpty()) {
            return null;
        }

        Admin admin = adminOpt.get();

        if (!passwordEncoder.matches(rawPassword, admin.getPassword())) {
            return null;
        }

        String token = generateToken();

        AdminToken adminToken = new AdminToken(
                admin.getId(),
                token,
                LocalDateTime.now(),
                LocalDateTime.now().plusHours(TOKEN_VALID_HOURS)
        );

        adminTokenRepository.save(adminToken);

        return new AdminLoginResult(admin, token);
    }

    /**
     * Validates a token from a request header. Returns the Admin if valid, otherwise null.
     */
    public Admin validateToken(String token) {

        if (token == null || token.isBlank()) {
            return null;
        }

        Optional<AdminToken> tokenOpt = adminTokenRepository.findByToken(token);

        if (tokenOpt.isEmpty()) {
            return null;
        }

        AdminToken adminToken = tokenOpt.get();

        if (adminToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            adminTokenRepository.delete(adminToken);
            return null;
        }

        return adminRepository.findById(adminToken.getAdminId()).orElse(null);
    }

    public void logout(String token) {
        adminTokenRepository.deleteByToken(token);
    }

    /** Utility for creating the very first admin account (call manually / via a setup script). */
    public Admin createAdmin(String name, String email, String rawPassword) {
        Admin admin = new Admin();
        admin.setName(name);
        admin.setEmail(email);
        admin.setPassword(passwordEncoder.encode(rawPassword));
        admin.setRole("ADMIN");
        return adminRepository.save(admin);
    }

    private String generateToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public static class AdminLoginResult {
        public final Admin admin;
        public final String token;

        public AdminLoginResult(Admin admin, String token) {
            this.admin = admin;
            this.token = token;
        }
    }
}
