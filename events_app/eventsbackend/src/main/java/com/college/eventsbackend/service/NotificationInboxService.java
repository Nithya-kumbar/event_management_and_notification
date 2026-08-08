package com.college.eventsbackend.service;

import com.college.eventsbackend.model.Notification;
import com.college.eventsbackend.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class NotificationInboxService {

    @Autowired
    private NotificationRepository notificationRepository;

    /** All notifications for a user — for the bell inbox screen */
    public List<Map<String, Object>> getNotifications(Integer userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toMap)
                .collect(Collectors.toList());
    }

    /** Unread count for badge on bell icon */
    public long getUnreadCount(Integer userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    /** Mark a single notification as read */
    public Map<String, Object> markRead(Integer notificationId) {
        Map<String, Object> response = new HashMap<>();
        Notification n = notificationRepository.findById(notificationId).orElse(null);
        if (n == null) {
            response.put("success", false);
            response.put("message", "Notification not found");
            return response;
        }
        n.setIsRead(true);
        notificationRepository.save(n);
        response.put("success", true);
        return response;
    }

    /** Mark all notifications as read for a user */
    public Map<String, Object> markAllRead(Integer userId) {
        List<Notification> unread = notificationRepository.findByUserIdAndIsReadFalse(userId);
        unread.forEach(n -> n.setIsRead(true));
        notificationRepository.saveAll(unread);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("marked", unread.size());
        return response;
    }

    private Map<String, Object> toMap(Notification n) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", n.getId());
        map.put("type", n.getType());
        map.put("title", n.getTitle());
        map.put("message", n.getMessage());
        map.put("isRead", n.getIsRead());
        map.put("eventId", n.getEventId());
        map.put("createdAt", n.getCreatedAt());
        return map;
    }
}
