package com.college.eventsbackend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.service.RegistrationService;
@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class RegistrationController {
 public RegistrationController() {
        System.out.println("RegistrationController Loaded");
    }
    @Autowired
    private RegistrationService registrationService;

    @PostMapping("/register-event")
    public String registerEvent(
            @RequestParam Integer userId,
            @RequestParam Integer eventId) {

        return registrationService.registerForEvent(userId, eventId);
    }
    @GetMapping("/user-registrations")
public Object getUserRegistrations(
        @RequestParam Integer userId) {

    return registrationService.getUserRegistrations(userId);
    
}
@GetMapping("/registration-count")
public long getRegistrationCount(
        @RequestParam Integer userId) {

    return registrationService.getRegistrationCount(userId);
}
}


 