package com.college.eventsbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.college.eventsbackend.model.Event;

public interface EventRepository extends JpaRepository<Event, Integer> {
}