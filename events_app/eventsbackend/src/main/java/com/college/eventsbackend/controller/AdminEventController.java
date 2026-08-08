package com.college.eventsbackend.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.college.eventsbackend.dto.UpdateEventRequest;
import com.college.eventsbackend.model.Event;
import com.college.eventsbackend.repository.EventRepository;
import com.college.eventsbackend.service.NotificationService;


@RestController
@RequestMapping("/api/admin/events")
@CrossOrigin(origins = "*")
public class AdminEventController {

    @Autowired
    private EventRepository eventRepository;
    @Autowired
private NotificationService notificationService;

    private static final long MAX_SIZE = 2L * 1024 * 1024; // 2MB
    private static final List<String> ALLOWED_EXT = List.of("jpg", "jpeg", "pdf");

    @GetMapping
    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    // NEW: upload brochure image/pdf, returns the URL + detected type
    @PostMapping("/upload")
    public Map<String, Object> uploadFile(@RequestParam("file") MultipartFile file) {
        Map<String, Object> response = new HashMap<>();

        if (file.isEmpty()) {
            response.put("success", false);
            response.put("message", "No file provided");
            return response;
        }

        if (file.getSize() > MAX_SIZE) {
            response.put("success", false);
            response.put("message", "File exceeds 2MB limit");
            return response;
        }

        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase();
        }

        if (!ALLOWED_EXT.contains(ext)) {
            response.put("success", false);
            response.put("message", "Only JPG and PDF files are allowed");
            return response;
        }

        try {
            Path uploadPath = Paths.get("uploads");
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String storedName = UUID.randomUUID().toString() + "." + ext;
            Path target = uploadPath.resolve(storedName);
            Files.copy(file.getInputStream(), target);

            String fileType = ext.equals("pdf") ? "PDF" : "IMAGE";

            response.put("success", true);
            response.put("url", "/uploads/" + storedName);
            response.put("fileType", fileType);
            return response;

        } catch (IOException e) {
            response.put("success", false);
            response.put("message", "Failed to save file: " + e.getMessage());
            return response;
        }
    }

    @PostMapping
    public Map<String, Object> createEvent(@RequestBody UpdateEventRequest req) {
        Map<String, Object> response = new HashMap<>();

        if (req.getEventName() == null || req.getEventName().isBlank()) {
            response.put("success", false);
            response.put("message", "Event name is required");
            return response;
        }
        if (req.getEventDate() == null) {
            response.put("success", false);
            response.put("message", "Event date is required");
            return response;
        }

        Event event = new Event();
        applyFields(event, req);
        eventRepository.save(event);
        notificationService.notifyNewEvent(event);
        response.put("success", true);
        response.put("message", "Event created successfully");
        response.put("eventId", event.getId());
        return response;
    }

    @PutMapping("/{eventId}")
    public Map<String, Object> updateEvent(@PathVariable Integer eventId,
                                            @RequestBody UpdateEventRequest req) {
        Map<String, Object> response = new HashMap<>();
        Event event = eventRepository.findById(eventId).orElse(null);
        if (event == null) {
            response.put("success", false);
            response.put("message", "Event not found");
            return response;
        }

        applyFields(event, req);
        eventRepository.save(event);

        response.put("success", true);
        response.put("message", "Event updated successfully");
        response.put("eventId", event.getId());
        return response;
    }

    @DeleteMapping("/{eventId}")
    public Map<String, Object> deleteEvent(@PathVariable Integer eventId) {
        Map<String, Object> response = new HashMap<>();
        if (!eventRepository.existsById(eventId)) {
            response.put("success", false);
            response.put("message", "Event not found");
            return response;
        }
        eventRepository.deleteById(eventId);
        response.put("success", true);
        response.put("message", "Event deleted");
        return response;
    }

    private void applyFields(Event event, UpdateEventRequest req) {
        if (req.getEventName() != null && !req.getEventName().isBlank())
            event.setEventName(req.getEventName());
        if (req.getDescription() != null) event.setDescription(req.getDescription());
        if (req.getDepartment() != null && !req.getDepartment().isBlank())
            event.setDepartment(req.getDepartment());
        if (req.getEventDate() != null) event.setEventDate(req.getEventDate());
        if (req.getEventTime() != null && !req.getEventTime().isBlank())
            event.setEventTime(req.getEventTime());
        if (req.getLocation() != null && !req.getLocation().isBlank())
            event.setLocation(req.getLocation());
        if (req.getCategory() != null && !req.getCategory().isBlank())
            event.setCategory(req.getCategory());
        if (req.getOrganizer() != null && !req.getOrganizer().isBlank())
            event.setOrganizer(req.getOrganizer());
        if (req.getRegistrationLink() != null) event.setRegistrationLink(req.getRegistrationLink());
        if (req.getImageUrl() != null) event.setImageUrl(req.getImageUrl());
        if (req.getFileType() != null) event.setFileType(req.getFileType());
        event.setRegistrationDueDate(req.getRegistrationDueDate());
    }
}