package com.college.eventsbackend.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.college.eventsbackend.security.AdminAuthFilter;

@Configuration
public class FilterConfig {

    @Autowired
    private AdminAuthFilter adminAuthFilter;

    @Bean
    public FilterRegistrationBean<AdminAuthFilter> adminAuthFilterRegistration() {
        FilterRegistrationBean<AdminAuthFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(adminAuthFilter);
        registrationBean.addUrlPatterns("/api/admin/*");
        registrationBean.setOrder(1);
        return registrationBean;
    }
}
