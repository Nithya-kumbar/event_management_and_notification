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
public class RegistrationService {

    @Autowired
    private RegistrationRepository registrationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EventRepository eventRepository;

    public String registerForEvent(Integer userId, Integer eventId) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found"));

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

        Event event = eventRepository.findById(registration.getEventId())
                .orElse(null);

        if (event == null) continue;

        Map<String, Object> map = new HashMap<>();

        map.put("registrationId", registration.getId());
        map.put("status", registration.getStatus());

        map.put("eventId", event.getId());
        map.put("eventName", event.getEventName());
        map.put("department", event.getDepartment());
        map.put("category", event.getCategory());
        map.put("description", event.getDescription());
        map.put("location", event.getLocation());
        map.put("eventDate", event.getEventDate());
        map.put("eventTime", event.getEventTime());

        result.add(map);
    }

    return result;
}
public long getRegistrationCount(Integer userId) {
    return registrationRepository.countByUserId(userId);
}
}