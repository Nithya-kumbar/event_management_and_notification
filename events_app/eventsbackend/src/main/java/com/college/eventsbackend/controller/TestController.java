package com.college.eventsbackend.controller;

import java.util.List;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.college.eventsbackend.model.Event;
import com.college.eventsbackend.repository.EventRepository;

@RestController
@CrossOrigin(origins = "*")   // <-- THE FIX: allow the Flutter web app's origin to call this controller
public class TestController {

    private final EventRepository eventRepository;

    public TestController(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    @GetMapping("/api/events")
    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    @PostMapping("/api/events")
    public Event addEvent(@RequestBody Event event) {
        return eventRepository.save(event);
    }
}