package com.college.eventsbackend.dto;

public class AddRegistrationRequest {

    private Integer userId;
    private Integer eventId;
    private String status; // optional, defaults to REGISTERED

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getEventId() { return eventId; }
    public void setEventId(Integer eventId) { this.eventId = eventId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
