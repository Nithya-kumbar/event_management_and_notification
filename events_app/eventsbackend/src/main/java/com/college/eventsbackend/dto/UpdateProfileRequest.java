package com.college.eventsbackend.dto;

public class UpdateProfileRequest {

    private Integer userId; // whose profile is being updated — must match authenticated/requesting user
    private String name;
    private String email;
    private String department;
    private String phone;

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
