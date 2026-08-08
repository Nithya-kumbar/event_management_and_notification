package com.college.eventsbackend.repository;

import com.college.eventsbackend.model.AppNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface AppNotificationRepository extends JpaRepository<AppNotification, Integer> {

    // All notifications for a user, newest first
    List<AppNotification> findByUserIdOrderByCreatedAtDesc(Integer userId);

    // Unread count
    long countByUserIdAndIsReadFalse(Integer userId);

    // Check duplicate — prevents sending same notification twice
    boolean existsByUserIdAndEventIdAndNotificationType(Integer userId, Integer eventId, String type);

    // Mark all as read for a user
    @Modifying
    @Transactional
    @Query("UPDATE AppNotification n SET n.isRead = true WHERE n.userId = :userId")
    void markAllReadForUser(Integer userId);
}
