package com.college.eventsbackend.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.dto.AddRegistrationRequest;
import com.college.eventsbackend.service.AdminRegistrationService;

@RestController
@RequestMapping("/api/admin/registrations")
@CrossOrigin(origins = "*")
public class AdminRegistrationController {

    @Autowired
    private AdminRegistrationService adminRegistrationService;

    // View all registrations, optionally filtered by event and/or student
    @GetMapping
    public List<Map<String, Object>> getRegistrations(
            @RequestParam(required = false) Integer eventId,
            @RequestParam(required = false) Integer userId) {

        return adminRegistrationService.getRegistrations(eventId, userId);
    }

    // Delete (remove a student from an event)
    @DeleteMapping("/{registrationId}")
    public Map<String, Object> deleteRegistration(@PathVariable Integer registrationId) {
        return adminRegistrationService.deleteRegistration(registrationId);
    }

    // Manually add a registration for a student
    @PostMapping
    public Map<String, Object> addRegistration(@RequestBody AddRegistrationRequest request) {
        return adminRegistrationService.addRegistration(
                request.getUserId(), request.getEventId(), request.getStatus());
    }
}
