package com.college.eventsbackend.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.college.eventsbackend.model.Event;
import com.college.eventsbackend.model.Registration;
import com.college.eventsbackend.repository.EventRepository;
import com.college.eventsbackend.repository.RegistrationRepository;
import com.college.eventsbackend.repository.UserRepository;

@Service
public class RegistrationService {

    @Autowired private RegistrationRepository registrationRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private EventRepository eventRepository;

public String registerForEvent(Integer userId, Integer eventId) {

    userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

    Event event = eventRepository.findById(eventId)
            .orElseThrow(() -> new RuntimeException("Event not found"));

    if (java.time.LocalDate.now().isAfter(event.getEffectiveDueDate())) {
        return "Registration Closed";
    }

    if (registrationRepository.existsByUserIdAndEventId(userId, eventId)) {
        return "Already Registered";
    }

    Registration registration = new Registration();
    registration.setUserId(userId);
    registration.setEventId(eventId);
    registration.setRegisteredAt(LocalDateTime.now());
    registration.setStatus("REGISTERED");
    registrationRepository.save(registration);

    return "Registration Successful";
}

    public List<Map<String, Object>> getUserRegistrations(Integer userId) {
    List<Registration> registrations =
            registrationRepository.findByUserIdOrderByRegisteredAtDesc(userId);
    List<Map<String, Object>> result = new ArrayList<>();

    for (Registration registration : registrations) {
        Event event = eventRepository.findById(registration.getEventId()).orElse(null);
        if (event == null) continue;

        Map<String, Object> map = new HashMap<>();
        map.put("registrationId", registration.getId());
        map.put("status", registration.getStatus());
        map.put("id", event.getId());
        map.put("eventId", event.getId());
        map.put("event_name", event.getEventName());
        map.put("eventName", event.getEventName());
        map.put("department", event.getDepartment());
        map.put("category", event.getCategory());
        map.put("description", event.getDescription());
        map.put("location", event.getLocation());
        map.put("event_date", event.getEventDate());
        map.put("eventDate", event.getEventDate());
        map.put("event_time", event.getEventTime());
        map.put("eventTime", event.getEventTime());
        map.put("image_url", event.getImageUrl());
        map.put("fileType", event.getFileType());
        map.put("organizer", event.getOrganizer());
        map.put("registration_link", event.getRegistrationLink());
        map.put("registration_due_date", event.getRegistrationDueDate());
        result.add(map);
    }
    return result;
}
    public Map<String, Object> cancelRegistration(Integer registrationId, Integer userId) {
        Map<String, Object> response = new HashMap<>();
        Registration reg = registrationRepository.findById(registrationId).orElse(null);
        if (reg == null) {
            response.put("success", false);
            response.put("message", "Registration not found");
            return response;
        }
        if (!reg.getUserId().equals(userId)) {
            response.put("success", false);
            response.put("message", "Forbidden");
            return response;
        }
        registrationRepository.delete(reg);
        response.put("success", true);
        response.put("message", "Registration cancelled");
        return response;
    }
}