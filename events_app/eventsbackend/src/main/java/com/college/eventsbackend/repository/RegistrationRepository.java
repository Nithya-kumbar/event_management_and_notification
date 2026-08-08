package com.college.eventsbackend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.college.eventsbackend.model.Registration;

public interface RegistrationRepository extends JpaRepository<Registration, Integer> {

    // Check if a user has already registered for an event
    boolean existsByUserIdAndEventId(Integer userId, Integer eventId);

    // Get all registrations of a user
    List<Registration> findByUserId(Integer userId);

    // Get all students registered for an event
    List<Registration> findByEventId(Integer eventId);

    List<Registration> findByUserIdOrderByRegisteredAtDesc(Integer userId);

    long countByUserId(Integer userId);

    // --- Admin filtering support ---
    List<Registration> findByUserIdAndEventId(Integer userId, Integer eventId);

    // For reminder scheduling: registrations for an event with a given status
    List<Registration> findByEventIdAndStatus(Integer eventId, String status);
}
