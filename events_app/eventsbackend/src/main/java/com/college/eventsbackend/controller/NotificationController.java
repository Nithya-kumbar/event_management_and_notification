package com.college.eventsbackend.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.service.NotificationService;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/notifications")
    public List<Map<String, Object>> getNotifications(@RequestParam Integer userId) {
        return notificationService.getUserNotifications(userId);
    }

    @GetMapping("/notifications/unread-count")
    public Map<String, Object> getUnreadCount(@RequestParam Integer userId) {
        long count = notificationService.getUnreadCount(userId);
        return Map.of("count", count);
    }

    @GetMapping("/notifications/unread")
public List<Map<String, Object>> getUnread(@RequestParam Integer userId) {
    return notificationService.getUnreadNotifications(userId);
}

    @PostMapping("/notifications/{notificationId}/read")
    public Map<String, Object> markRead(@PathVariable Integer notificationId) {
        return notificationService.markOneRead(notificationId);
    }

    @PostMapping("/notifications/mark-all-read")
    public Map<String, Object> markAllRead(@RequestParam Integer userId) {
        notificationService.markAllRead(userId);
        return Map.of("success", true);
    }
}
