package com.college.eventsbackend.scheduler;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.college.eventsbackend.service.NotificationService;

@Component
public class NotificationScheduler {

    @Autowired
    private NotificationService notificationService;

    @Scheduled(fixedRate = 60000)
    public void runNotifications() {
        try {
            notificationService.processAllNotifications();
        } catch (Exception e) {
            System.err.println("Notification scheduler error: " + e.getMessage());
        }
    }
}
