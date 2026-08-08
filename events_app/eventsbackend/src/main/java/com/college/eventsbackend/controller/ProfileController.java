package com.college.eventsbackend.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.dto.UpdateProfileRequest;
import com.college.eventsbackend.service.ProfileService;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    // View own profile
    @GetMapping("/profile")
    public Map<String, Object> getProfile(@RequestParam Integer userId) {
        return profileService.getProfile(userId);
    }

    // Edit own profile.
    // requestingUserId is passed as a query param representing "who is making this call"
    // (the logged-in user's id on the Flutter side) and must match the body's userId.
    @PutMapping("/profile")
    public Map<String, Object> updateProfile(
            @RequestParam Integer requestingUserId,
            @RequestBody UpdateProfileRequest request) {

        return profileService.updateProfile(
                requestingUserId,
                request.getUserId(),
                request.getName(),
                request.getEmail(),
                request.getDepartment(),
                request.getPhone()
        );
    }
}
