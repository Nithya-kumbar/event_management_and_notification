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
import com.college.eventsbackend.model.User;
import com.college.eventsbackend.repository.EventRepository;
import com.college.eventsbackend.repository.RegistrationRepository;
import com.college.eventsbackend.repository.UserRepository;

@Service
public class AdminRegistrationService {

    @Autowired
    private RegistrationRepository registrationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EventRepository eventRepository;

    /** Returns all registrations, optionally filtered by eventId and/or userId, enriched with event + user info. */
    public List<Map<String, Object>> getRegistrations(Integer eventId, Integer userId) {

        List<Registration> registrations;

        if (eventId != null && userId != null) {
            registrations = registrationRepository.findByUserIdAndEventId(userId, eventId);
        } else if (eventId != null) {
            registrations = registrationRepository.findByEventId(eventId);
        } else if (userId != null) {
            registrations = registrationRepository.findByUserId(userId);
        } else {
            registrations = registrationRepository.findAll();
        }

        List<Map<String, Object>> result = new ArrayList<>();

        for (Registration registration : registrations) {

            Map<String, Object> map = new HashMap<>();
            map.put("registrationId", registration.getId());
            map.put("status", registration.getStatus());
            map.put("registeredAt", registration.getRegisteredAt());

            User user = userRepository.findById(registration.getUserId()).orElse(null);
            Event event = eventRepository.findById(registration.getEventId()).orElse(null);

            if (user != null) {
                map.put("userId", user.getId());
                map.put("userName", user.getName());
                map.put("userEmail", user.getEmail());
                map.put("userUsn", user.getUsn());
                map.put("userDepartment", user.getDepartment());
            }

            if (event != null) {
                map.put("eventId", event.getId());
                map.put("eventName", event.getEventName());
                map.put("eventDate", event.getEventDate());
                map.put("eventTime", event.getEventTime());
            }

            result.add(map);
        }

        return result;
    }

    public Map<String, Object> deleteRegistration(Integer registrationId) {

        Map<String, Object> response = new HashMap<>();

        if (!registrationRepository.existsById(registrationId)) {
            response.put("success", false);
            response.put("message", "Registration not found");
            return response;
        }

        registrationRepository.deleteById(registrationId);

        response.put("success", true);
        response.put("message", "Registration deleted");
        return response;
    }

    public Map<String, Object> addRegistration(Integer userId, Integer eventId, String status) {

        Map<String, Object> response = new HashMap<>();

        if (!userRepository.existsById(userId)) {
            response.put("success", false);
            response.put("message", "User not found");
            return response;
        }

        if (!eventRepository.existsById(eventId)) {
            response.put("success", false);
            response.put("message", "Event not found");
            return response;
        }

        if (registrationRepository.existsByUserIdAndEventId(userId, eventId)) {
            response.put("success", false);
            response.put("message", "User is already registered for this event");
            return response;
        }

        Registration registration = new Registration();
        registration.setUserId(userId);
        registration.setEventId(eventId);
        registration.setRegisteredAt(LocalDateTime.now());
        registration.setStatus(status != null && !status.isBlank() ? status : "REGISTERED");

        registrationRepository.save(registration);

        response.put("success", true);
        response.put("message", "Registration added");
        response.put("registrationId", registration.getId());
        return response;
    }
}
