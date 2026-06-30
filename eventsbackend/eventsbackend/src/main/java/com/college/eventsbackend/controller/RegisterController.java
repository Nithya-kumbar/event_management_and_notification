package com.college.eventsbackend.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.dto.RegisterRequest;
import com.college.eventsbackend.model.User;
import com.college.eventsbackend.repository.UserRepository;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class RegisterController {

    private final UserRepository userRepository;

    public RegisterController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody RegisterRequest request) {

        Map<String, Object> response = new HashMap<>();

        if (userRepository.existsByEmail(request.getEmail())) {
            response.put("success", false);
            response.put("message", "Email already registered");
            return response;
        }

        if (userRepository.existsByUsn(request.getUsn())) {
            response.put("success", false);
            response.put("message", "USN already registered");
            return response;
        }

        User user = new User();

        user.setName(request.getName());
        user.setUsn(request.getUsn());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
        user.setDepartment(request.getDepartment());

        userRepository.save(user);

        response.put("success", true);
        response.put("message", "Registration successful");

        return response;
    }
}