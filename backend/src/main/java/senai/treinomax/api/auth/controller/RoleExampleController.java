package senai.treinomax.api.auth.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.auth.model.Role;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/examples")
@RequiredArgsConstructor
@Slf4j
public class RoleExampleController {

    @GetMapping("/only-admin")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> onlyAdmin() {
        log.info("Admin endpoint accessed by user: {}", SecurityUtils.getCurrentUserEmail());
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is only accessible by ADMIN users");
        response.put("user", SecurityUtils.getCurrentUserEmail());
        response.put("roles", SecurityUtils.getCurrentUserRoles());
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/only-customer")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<Map<String, Object>> onlyCustomer() {
        log.info("Customer endpoint accessed by user: {}", SecurityUtils.getCurrentUserEmail());
        log.info("{}", SecurityUtils.getCurrentUserRoles());

        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is only accessible by CUSTOMER users");
        response.put("user", SecurityUtils.getCurrentUserEmail());
        response.put("roles", SecurityUtils.getCurrentUserRoles());
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/only-personal")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Map<String, Object>> onlyPersonal() {
        log.info("Personal endpoint accessed by user: {}", SecurityUtils.getCurrentUserEmail());
        log.info("{}", SecurityUtils.getCurrentUserRoles());
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is only accessible by PERSONAL users");
        response.put("user", SecurityUtils.getCurrentUserEmail());
        response.put("roles", SecurityUtils.getCurrentUserRoles());
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/admin-or-personal")
    @PreAuthorize("hasAnyRole('ADMIN', 'PERSONAL')")
    public ResponseEntity<Map<String, Object>> adminOrPersonal() {
        log.info("Admin or Personal endpoint accessed by user: {}", SecurityUtils.getCurrentUserEmail());
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is accessible by ADMIN or PERSONAL users");
        response.put("user", SecurityUtils.getCurrentUserEmail());
        response.put("roles", SecurityUtils.getCurrentUserRoles());
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/any-authenticated")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> anyAuthenticated() {
        log.info("Any authenticated endpoint accessed by user: {}", SecurityUtils.getCurrentUserEmail());
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This endpoint is accessible by any authenticated user");
        response.put("user", SecurityUtils.getCurrentUserEmail());
        response.put("roles", SecurityUtils.getCurrentUserRoles());
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }
}