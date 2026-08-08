package com.college.eventsbackend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.college.eventsbackend.model.AdminToken;

public interface AdminTokenRepository extends JpaRepository<AdminToken, Integer> {

    Optional<AdminToken> findByToken(String token);

    void deleteByToken(String token);
}
