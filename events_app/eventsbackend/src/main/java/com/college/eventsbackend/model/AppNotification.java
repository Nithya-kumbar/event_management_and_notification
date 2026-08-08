package com.college.eventsbackend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "app_notifications", indexes = {
    @Index(name = "idx_notif_user", columnList = "user_id"),
    @Index(name = "idx_notif_read", columnList = "user_id, is_read")
})
public class AppNotification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "event_id")
    private Integer eventId;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, length = 500)
    private String message;

    // REMINDER_1_DAY, REMINDER_1_HOUR, REMINDER_15_MIN, EVENT_START,
    // DEADLINE_UNREGISTERED (for non-registered users)
    @Column(name = "notification_type", nullable = false)
    private String notificationType;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public AppNotification() {}

    public AppNotification(Integer userId, Integer eventId, String title,
                           String message, String notificationType) {
        this.userId = userId;
        this.eventId = eventId;
        this.title = title;
        this.message = message;
        this.notificationType = notificationType;
        this.createdAt = LocalDateTime.now();
        this.isRead = false;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getNotificationType() { return notificationType; }
    public void setNotificationType(String t) { this.notificationType = t; }

    public Boolean getIsRead() { return isRead; }
    public void setIsRead(Boolean isRead) { this.isRead = isRead; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
