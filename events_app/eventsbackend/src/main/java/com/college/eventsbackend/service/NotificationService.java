package com.college.eventsbackend.service;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.college.eventsbackend.model.AppNotification;
import com.college.eventsbackend.model.Event;
import com.college.eventsbackend.model.Registration;
import com.college.eventsbackend.model.User;
import com.college.eventsbackend.repository.AppNotificationRepository;
import com.college.eventsbackend.repository.EventRepository;
import com.college.eventsbackend.repository.RegistrationRepository;
import com.college.eventsbackend.repository.UserRepository;

@Service
public class NotificationService {

    public static final String TYPE_1_DAY    = "REMINDER_1_DAY";
    public static final String TYPE_1_HOUR   = "REMINDER_1_HOUR";
    public static final String TYPE_15_MIN   = "REMINDER_15_MIN";
    public static final String TYPE_START    = "EVENT_START";
    public static final String TYPE_DEADLINE = "DEADLINE_UNREGISTERED";

    private static final long WINDOW_MINUTES = 2;

    @Autowired private AppNotificationRepository notifRepo;
    @Autowired private EventRepository eventRepository;
    @Autowired private RegistrationRepository registrationRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private EmailService emailService;

    // ----------------------------------------------------------------
    // Called by scheduler every minute — optimised to minimal queries
    // ----------------------------------------------------------------
    public void processAllNotifications() {
        LocalDateTime now = LocalDateTime.now();

        // 1 query: all events
        List<Event> events = eventRepository.findAll();

        // 1 query: all users → map for O(1) lookup
        Map<Integer, User> userMap = new HashMap<>();
        for (User u : userRepository.findAll()) {
            userMap.put(u.getId(), u);
        }

        // 1 query: all registrations → group by eventId
        Map<Integer, Set<Integer>> registeredByEvent = new HashMap<>();
        for (Registration reg : registrationRepository.findAll()) {
            if ("REGISTERED".equals(reg.getStatus())) {
                registeredByEvent
                    .computeIfAbsent(reg.getEventId(), k -> new HashSet<>())
                    .add(reg.getUserId());
            }
        }

        // 1 query: all already-sent notification keys → Set for O(1) dedup
        Set<String> sentKeys = new HashSet<>();
        for (AppNotification n : notifRepo.findAll()) {
            sentKeys.add(notifKey(n.getUserId(), n.getEventId(), n.getNotificationType()));
        }

        // Batch of new notifications to save at the end
        List<AppNotification> toSave = new ArrayList<>();
        List<String[]> emailsToSend = new ArrayList<>(); // [to, subject, body]

        for (Event event : events) {
            LocalDateTime eventStart = resolveEventStart(event);
            if (eventStart == null) continue;

            long minutesUntil = Duration.between(now, eventStart).toMinutes();

            String reminderType = null;
            String titleTemplate = null;
            String bodyTemplate  = null;

            if (isWithinWindow(minutesUntil, 24 * 60)) {
                reminderType   = TYPE_1_DAY;
                titleTemplate  = "Reminder: " + event.getEventName();
                bodyTemplate   = event.getEventName() + " is happening tomorrow at "
                                 + safe(event.getEventTime()) + ".";
            } else if (isWithinWindow(minutesUntil, 60)) {
                reminderType   = TYPE_1_HOUR;
                titleTemplate  = "Starting Soon: " + event.getEventName();
                bodyTemplate   = event.getEventName() + " starts in 1 hour at "
                                 + safe(event.getLocation()) + ".";
            } else if (isWithinWindow(minutesUntil, 15)) {
                reminderType   = TYPE_15_MIN;
                titleTemplate  = "15 Minutes: " + event.getEventName();
                bodyTemplate   = event.getEventName() + " starts in 15 minutes! Head to "
                                 + safe(event.getLocation()) + " now.";
            } else if (isWithinWindow(minutesUntil, 0)) {
                reminderType   = TYPE_START;
                titleTemplate  = event.getEventName() + " is starting now!";
                bodyTemplate   = "\"" + event.getEventName()
                                 + "\" is starting right now at " + safe(event.getLocation()) + ".";
            }

            Set<Integer> registeredIds = registeredByEvent.getOrDefault(
                    event.getId(), Collections.emptySet());

            // Registered user reminders
            if (reminderType != null) {
                for (Integer userId : registeredIds) {
                    User user = userMap.get(userId);
                    if (user == null) continue;
                    String key = notifKey(userId, event.getId(), reminderType);
                    if (sentKeys.contains(key)) continue;
                    sentKeys.add(key);

                    AppNotification n = new AppNotification(
                        userId, event.getId(), titleTemplate, bodyTemplate, reminderType);
                    toSave.add(n);
                    if (user.getEmail() != null && !user.getEmail().isBlank()) {
                        emailsToSend.add(new String[]{
                            user.getEmail(), titleTemplate,
                            buildEmailBody(user, event, bodyTemplate)
                        });
                    }
                }
            }

            // Unregistered users — 1-day deadline only
            if (isWithinWindow(minutesUntil, 24 * 60)) {
                String deadlineTitle = "Don't miss: " + event.getEventName();
                String deadlineBody  = "\"" + event.getEventName()
                    + "\" is tomorrow and you haven't registered yet! Register before it's too late.";

                for (User user : userMap.values()) {
                    if (registeredIds.contains(user.getId())) continue;
                    String key = notifKey(user.getId(), event.getId(), TYPE_DEADLINE);
                    if (sentKeys.contains(key)) continue;
                    sentKeys.add(key);

                    toSave.add(new AppNotification(
                        user.getId(), event.getId(), deadlineTitle, deadlineBody, TYPE_DEADLINE));
                    if (user.getEmail() != null && !user.getEmail().isBlank()) {
                        emailsToSend.add(new String[]{
                            user.getEmail(), deadlineTitle,
                            buildEmailBody(user, event, deadlineBody)
                        });
                    }
                }
            }
        }

        // Batch save — 1 trip instead of N individual inserts
        if (!toSave.isEmpty()) {
            notifRepo.saveAll(toSave);
        }

        // Send emails after DB is committed (don't block on failures)
        for (String[] email : emailsToSend) {
            emailService.sendEmail(email[0], email[1], email[2]);
        }
    }

    // ----------------------------------------------------------------
    // API: Get all notifications for a user (inbox)
    // ----------------------------------------------------------------
    public List<Map<String, Object>> getUserNotifications(Integer userId) {
        List<AppNotification> notifications =
            notifRepo.findByUserIdOrderByCreatedAtDesc(userId);

        List<Map<String, Object>> result = new ArrayList<>();
        for (AppNotification n : notifications) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", n.getId());
            map.put("title", n.getTitle());
            map.put("message", n.getMessage());
            map.put("notificationType", n.getNotificationType());
            map.put("isRead", n.getIsRead());
            map.put("createdAt", n.getCreatedAt());
            map.put("eventId", n.getEventId());
            result.add(map);
        }
        return result;
    }

    public long getUnreadCount(Integer userId) {
        return notifRepo.countByUserIdAndIsReadFalse(userId);
    }

    public void markAllRead(Integer userId) {
        notifRepo.markAllReadForUser(userId);
    }

    public Map<String, Object> markOneRead(Integer notificationId) {
        Map<String, Object> response = new HashMap<>();
        AppNotification notif = notifRepo.findById(notificationId).orElse(null);
        if (notif == null) {
            response.put("success", false);
            response.put("message", "Notification not found");
            return response;
        }
        notif.setIsRead(true);
        notifRepo.save(notif);
        response.put("success", true);
        return response;
    }

    // ----------------------------------------------------------------
    // Helpers
    // ----------------------------------------------------------------
    private String notifKey(Integer userId, Integer eventId, String type) {
        return userId + ":" + eventId + ":" + type;
    }

    private boolean isWithinWindow(long minutesUntil, long target) {
        return Math.abs(minutesUntil - target) <= WINDOW_MINUTES;
    }

    private String buildEmailBody(User user, Event event, String message) {
        return "Hi " + safe(user.getName()) + ",\n\n"
            + message + "\n\n"
            + "Event: " + safe(event.getEventName()) + "\n"
            + "Date: " + event.getEventDate() + "\n"
            + "Time: " + safe(event.getEventTime()) + "\n"
            + "Location: " + safe(event.getLocation()) + "\n\n"
            + "- College Events Team";
    }

    private String safe(String v) { return v == null ? "" : v; }

    private static final DateTimeFormatter[] TIME_FORMATS = {
        DateTimeFormatter.ofPattern("h:mm a",   Locale.ENGLISH),
        DateTimeFormatter.ofPattern("hh:mm a",  Locale.ENGLISH),
        DateTimeFormatter.ofPattern("H:mm",     Locale.ENGLISH),
        DateTimeFormatter.ofPattern("HH:mm",    Locale.ENGLISH),
        DateTimeFormatter.ofPattern("HH:mm:ss", Locale.ENGLISH),
    };

    private LocalDateTime resolveEventStart(Event event) {
        LocalDate date = event.getEventDate();
        String timeStr = event.getEventTime();
        if (date == null || timeStr == null || timeStr.isBlank()) return null;
        for (DateTimeFormatter fmt : TIME_FORMATS) {
            try {
                LocalTime t = LocalTime.parse(timeStr.trim(), fmt);
                return LocalDateTime.of(date, t);
            } catch (DateTimeParseException ignored) {}
        }
        return null;
    }
    public static final String TYPE_NEW_EVENT = "NEW_EVENT";

// Called by AdminEventController right after a new event is created
public void notifyNewEvent(Event event) {
    String title = "New Event: " + event.getEventName();
    String body  = event.getEventName() + " has been added. Check it out!";

    List<AppNotification> toSave = new ArrayList<>();
    List<String[]> emailsToSend = new ArrayList<>();

    for (User user : userRepository.findAll()) {
        toSave.add(new AppNotification(
            user.getId(), event.getId(), title, body, TYPE_NEW_EVENT));

        if (user.getEmail() != null && !user.getEmail().isBlank()) {
            emailsToSend.add(new String[]{
                user.getEmail(), title, buildEmailBody(user, event, body)
            });
        }
    }

    if (!toSave.isEmpty()) {
        notifRepo.saveAll(toSave);
    }
    for (String[] email : emailsToSend) {
        emailService.sendEmail(email[0], email[1], email[2]);
    }
}

// Used by the Flutter polling client — only unread items
public List<Map<String, Object>> getUnreadNotifications(Integer userId) {
    List<AppNotification> all = notifRepo.findByUserIdOrderByCreatedAtDesc(userId);
    List<Map<String, Object>> result = new ArrayList<>();
    for (AppNotification n : all) {
        if (Boolean.TRUE.equals(n.getIsRead())) continue;
        Map<String, Object> map = new HashMap<>();
        map.put("id", n.getId());
        map.put("title", n.getTitle());
        map.put("message", n.getMessage());
        map.put("notificationType", n.getNotificationType());
        map.put("isRead", n.getIsRead());
        map.put("createdAt", n.getCreatedAt());
        map.put("eventId", n.getEventId());
        result.add(map);
    }
    return result;
}
}
