package com.college.eventsbackend.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.dto.LoginRequest;
import com.college.eventsbackend.model.User;
import com.college.eventsbackend.repository.UserRepository;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class LoginController {

private final UserRepository userRepository;

public LoginController(UserRepository userRepository) {
    this.userRepository = userRepository;
}

@PostMapping("/login")
public Map<String, Object> login(
        @RequestBody LoginRequest request) {

    Map<String, Object> response = new HashMap<>();

    Optional<User> userOpt =
            userRepository.findByEmail(request.getEmail());

    if (userOpt.isPresent()) {

        User user = userOpt.get();

        if (user.getPassword().equals(request.getPassword())) {

           response.put("success", true);
response.put("id", user.getId());
response.put("name", user.getName());
response.put("email", user.getEmail());
response.put("department", user.getDepartment());

            return response;
        }
    }

    response.put("success", false);
    response.put("message", "Invalid email or password");

    return response;
}


}
