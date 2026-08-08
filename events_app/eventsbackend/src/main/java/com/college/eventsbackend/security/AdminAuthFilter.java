package com.college.eventsbackend.security;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.college.eventsbackend.model.Admin;
import com.college.eventsbackend.service.AdminAuthService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Lightweight filter-based auth for admin routes.
 * Protects any path under /api/admin/** except /api/admin/login.
 * Expects header: X-Admin-Token: <token>
 */
@Component
public class AdminAuthFilter extends OncePerRequestFilter {

    @Autowired
    private AdminAuthService adminAuthService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                     HttpServletResponse response,
                                     FilterChain filterChain) throws ServletException, IOException {

        String path = request.getRequestURI();

        boolean isAdminRoute = path.startsWith("/api/admin/");
        boolean isLoginRoute = path.equals("/api/admin/login");

        // Allow CORS preflight through untouched
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            filterChain.doFilter(request, response);
            return;
        }

        if (!isAdminRoute || isLoginRoute) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = request.getHeader("X-Admin-Token");
        Admin admin = adminAuthService.validateToken(token);

        if (admin == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Unauthorized: invalid or missing admin token\"}");
            return;
        }

        // Stash admin id on request for downstream controllers if needed
        request.setAttribute("adminId", admin.getId());
        request.setAttribute("adminRole", admin.getRole());

        filterChain.doFilter(request, response);
    }
}
