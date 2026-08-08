package com.college.eventsbackend.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.dto.AdminLoginRequest;
import com.college.eventsbackend.model.Admin;
import com.college.eventsbackend.service.AdminAuthService;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminLoginController {

    @Autowired
    private AdminAuthService adminAuthService;

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody AdminLoginRequest request) {

        Map<String, Object> response = new HashMap<>();

        AdminAuthService.AdminLoginResult result =
                adminAuthService.login(request.getEmail(), request.getPassword());

        if (result == null) {
            response.put("success", false);
            response.put("message", "Invalid admin email or password");
            return response;
        }

        Admin admin = result.admin;

        response.put("success", true);
        response.put("token", result.token);
        response.put("id", admin.getId());
        response.put("name", admin.getName());
        response.put("email", admin.getEmail());
        response.put("role", admin.getRole());

        return response;
    }

    @PostMapping("/logout")
    public Map<String, Object> logout(@RequestHeader("X-Admin-Token") String token) {
        adminAuthService.logout(token);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Logged out");
        return response;
    }
}
