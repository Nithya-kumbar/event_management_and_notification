package com.college.eventsbackend.dto;

import java.time.LocalDate;

import com.fasterxml.jackson.annotation.JsonProperty;

public class UpdateEventRequest {

    @JsonProperty("event_name")
    private String eventName;
    private String description;
    private String department;

    @JsonProperty("event_date")
    private LocalDate eventDate;

    @JsonProperty("event_time")
    private String eventTime;

    private String location;
    private String category;
    private String organizer;

    @JsonProperty("registration_link")
    private String registrationLink;

    @JsonProperty("image_url")
    private String imageUrl;

    @JsonProperty("file_type")
private String fileType;

public String getFileType() { return fileType; }
public void setFileType(String f) { this.fileType = f; }

    public String getEventName() { return eventName; }
    public void setEventName(String n) { this.eventName = n; }
    public String getDescription() { return description; }
    public void setDescription(String d) { this.description = d; }
    public String getDepartment() { return department; }
    public void setDepartment(String d) { this.department = d; }
    public LocalDate getEventDate() { return eventDate; }
    public void setEventDate(LocalDate d) { this.eventDate = d; }
    public String getEventTime() { return eventTime; }
    public void setEventTime(String t) { this.eventTime = t; }
    public String getLocation() { return location; }
    public void setLocation(String l) { this.location = l; }
    public String getCategory() { return category; }
    public void setCategory(String c) { this.category = c; }
    public String getOrganizer() { return organizer; }
    public void setOrganizer(String o) { this.organizer = o; }
    public String getRegistrationLink() { return registrationLink; }
    public void setRegistrationLink(String r) { this.registrationLink = r; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String i) { this.imageUrl = i; }
    @JsonProperty("registration_due_date")
private LocalDate registrationDueDate;

public LocalDate getRegistrationDueDate() { return registrationDueDate; }
public void setRegistrationDueDate(LocalDate d) { this.registrationDueDate = d; }
}
