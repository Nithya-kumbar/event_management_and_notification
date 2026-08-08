package com.college.eventsbackend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.college.eventsbackend.model.ReminderLog;

public interface ReminderLogRepository extends JpaRepository<ReminderLog, Integer> {

    boolean existsByUserIdAndEventIdAndReminderType(Integer userId, Integer eventId, String reminderType);

    List<ReminderLog> findByEventId(Integer eventId);

    List<ReminderLog> findByUserId(Integer userId);

    List<ReminderLog> findByUserIdAndAcknowledgedFalseOrderBySentAtDesc(Integer userId);
}
