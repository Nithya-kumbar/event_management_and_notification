package com.college.eventsbackend.controller;

import com.college.eventsbackend.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Kept for backward compatibility with any existing Flutter calls to /api/reminders/*.
 * Delegates to NotificationService which now handles all reminder logic.
 * New Flutter code should use NotificationController (/api/notifications) instead.
 */
@RestController
@RequestMapping("/api/reminders")
@CrossOrigin(origins = "*")
public class ReminderController {

    @Autowired
    private NotificationService notificationService;

    // Legacy endpoint — Flutter pending reminders poll
    @GetMapping("/pending")
    public List<Map<String, Object>> getPending(@RequestParam Integer userId) {
        return notificationService.getUserNotifications(userId);
    }

    // Legacy endpoint — acknowledge a reminder
    @PostMapping("/{reminderId}/acknowledge")
    public Map<String, Object> acknowledge(@PathVariable Integer reminderId) {
        return notificationService.markOneRead(reminderId);
    }
}
