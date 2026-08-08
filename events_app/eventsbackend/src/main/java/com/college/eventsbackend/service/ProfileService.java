package com.college.eventsbackend.service;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.college.eventsbackend.model.User;
import com.college.eventsbackend.repository.UserRepository;

@Service
public class ProfileService {

    @Autowired
    private UserRepository userRepository;

    public Map<String, Object> getProfile(Integer userId) {

        Map<String, Object> response = new HashMap<>();

        Optional<User> userOpt = userRepository.findById(userId);

        if (userOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "User not found");
            return response;
        }

        User user = userOpt.get();

        response.put("success", true);
        response.put("id", user.getId());
        response.put("name", user.getName());
        response.put("usn", user.getUsn());
        response.put("email", user.getEmail());
        response.put("department", user.getDepartment());
        response.put("phone", user.getPhone());

        return response;
    }

    /**
     * Updates a user's own profile.
     * requestingUserId must equal targetUserId — this is the access-control boundary
     * preventing a student from editing another student's profile, given the app's
     * current no-JWT, client-supplied-id auth model.
     */
    public Map<String, Object> updateProfile(Integer requestingUserId, Integer targetUserId,
                                              String name, String email, String department, String phone) {

        Map<String, Object> response = new HashMap<>();

        if (requestingUserId == null || !requestingUserId.equals(targetUserId)) {
            response.put("success", false);
            response.put("message", "Forbidden: you can only edit your own profile");
            return response;
        }

        Optional<User> userOpt = userRepository.findById(targetUserId);

        if (userOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "User not found");
            return response;
        }

        User user = userOpt.get();

        // Basic validation
        if (name != null && name.isBlank()) {
            response.put("success", false);
            response.put("message", "Name cannot be empty");
            return response;
        }

        if (email != null) {
            if (email.isBlank() || !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                response.put("success", false);
                response.put("message", "Invalid email format");
                return response;
            }

            if (!email.equalsIgnoreCase(user.getEmail()) && userRepository.existsByEmail(email)) {
                response.put("success", false);
                response.put("message", "Email already in use");
                return response;
            }
        }

        if (phone != null && !phone.isBlank() && !phone.matches("^[0-9+\\-\\s]{7,15}$")) {
            response.put("success", false);
            response.put("message", "Invalid phone number format");
            return response;
        }

        if (name != null && !name.isBlank()) user.setName(name);
        if (email != null && !email.isBlank()) user.setEmail(email);
        if (department != null && !department.isBlank()) user.setDepartment(department);
        if (phone != null) user.setPhone(phone);

        userRepository.save(user);

        response.put("success", true);
        response.put("message", "Profile updated successfully");
        response.put("id", user.getId());
        response.put("name", user.getName());
        response.put("email", user.getEmail());
        response.put("department", user.getDepartment());
        response.put("phone", user.getPhone());

        return response;
    }
}
