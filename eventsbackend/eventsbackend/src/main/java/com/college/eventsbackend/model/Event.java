package com.college.eventsbackend.model;

import java.time.LocalDate;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "events")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    //  @JsonProperty("event_name")
    //  private String title;
    @JsonProperty("event_name")
@Column(name = "event_name")
private String eventName;
    private String description;

    private String department;

    @JsonProperty("event_date")
    @Column(name = "event_date")
    private LocalDate eventDate;

    @JsonProperty("event_time")
    @Column(name = "event_time")
    private String eventTime;

    private String location;

    private String category;

    @JsonProperty("registration_link")
   // @Transient
    private String registrationLink;

    @JsonProperty("image_url")
   // @Transient
    private String imageUrl;

   //@Transient
    private String organizer = "College Department";

    // Getters and Setters

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @JsonProperty("event_name")
    // public String getTitle() {
    //     return title;
    // }
    public String getEventName() {
    return eventName;
}

public void setEventName(String eventName) {
    this.eventName = eventName;
}

    // public void setTitle(String title) {
    //     this.title = title;
    // }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    @JsonProperty("event_date")
    public LocalDate getEventDate() {
        return eventDate;
    }

    public void setEventDate(LocalDate eventDate) {
        this.eventDate = eventDate;
    }

    @JsonProperty("event_time")
    public String getEventTime() {
        return eventTime;
    }

    public void setEventTime(String eventTime) {
        this.eventTime = eventTime;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getRegistrationLink() {
        return registrationLink;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public String getOrganizer() {
        return organizer;
    }
}