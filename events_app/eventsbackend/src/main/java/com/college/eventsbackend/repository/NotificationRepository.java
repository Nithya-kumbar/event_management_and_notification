package com.college.eventsbackend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.college.eventsbackend.model.Notification;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    // All notifications for a user, newest first (for the bell inbox)
    List<Notification> findByUserIdOrderByCreatedAtDesc(Integer userId);

    // Unread count for badge
    long countByUserIdAndIsReadFalse(Integer userId);

    // Check if a notification of this type was already sent (dedup)
    boolean existsByUserIdAndEventIdAndType(Integer userId, Integer eventId, String type);

    // Mark all read for a user
    List<Notification> findByUserIdAndIsReadFalse(Integer userId);
}
