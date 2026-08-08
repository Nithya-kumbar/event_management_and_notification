package com.college.eventsbackend.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "reminder_logs")
public class ReminderLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "event_id")
    private Integer eventId;

    @Column(name = "reminder_type") // e.g. "1_DAY", "1_HOUR", "15_MIN", "EVENT_START"
    private String reminderType;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    @Column(name = "email_sent")
    private Boolean emailSent = false;

    // Whether the student has acknowledged/dismissed this as an in-app popup.
    // Defaults to false so newly created reminders show up as "pending" popups.
    @Column(name = "acknowledged")
    private Boolean acknowledged = false;

    public ReminderLog() {}

    public ReminderLog(Integer userId, Integer eventId, String reminderType) {
        this.userId = userId;
        this.eventId = eventId;
        this.reminderType = reminderType;
        this.sentAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }

    public String getReminderType() { return reminderType; }
    public void setReminderType(String reminderType) { this.reminderType = reminderType; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }

    public Boolean getEmailSent() { return emailSent; }
    public void setEmailSent(Boolean emailSent) { this.emailSent = emailSent; }

    public Boolean getAcknowledged() { return acknowledged; }
    public void setAcknowledged(Boolean acknowledged) { this.acknowledged = acknowledged; }
}
