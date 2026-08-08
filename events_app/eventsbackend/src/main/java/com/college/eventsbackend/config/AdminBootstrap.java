package com.college.eventsbackend.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.college.eventsbackend.repository.AdminRepository;
import com.college.eventsbackend.service.AdminAuthService;

/**
 * Creates a default admin account on startup if no admin exists yet.
 * Configure via application.properties:
 *   app.admin.default-email=admin@college.edu
 *   app.admin.default-password=ChangeMe123!
 *   app.admin.default-name=Super Admin
 * Change the password immediately after first login in production.
 */
@Component
public class AdminBootstrap implements CommandLineRunner {

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private AdminAuthService adminAuthService;

    @Value("${app.admin.default-email:admin@college.edu}")
    private String defaultEmail;

    @Value("${app.admin.default-password:ChangeMe123!}")
    private String defaultPassword;

    @Value("${app.admin.default-name:Super Admin}")
    private String defaultName;

    @Override
    public void run(String... args) {
        if (adminRepository.count() == 0) {
            adminAuthService.createAdmin(defaultName, defaultEmail, defaultPassword);
            System.out.println("Default admin account created: " + defaultEmail
                    + " (please change the password after first login)");
        }
    }
}
