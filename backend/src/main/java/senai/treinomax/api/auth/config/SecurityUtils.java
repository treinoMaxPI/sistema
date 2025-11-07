package senai.treinomax.api.auth.config;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import senai.treinomax.api.auth.model.Role;
import senai.treinomax.api.auth.service.CustomUserDetailsService;

import java.util.Collection;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

public class SecurityUtils {

    public static boolean hasRole(Role role) {
        Collection<? extends GrantedAuthority> authorities = SecurityContextHolder.getContext()
                .getAuthentication()
                .getAuthorities();
        
        return authorities.contains(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    public static boolean hasAnyRole(Role... roles) {
        Collection<? extends GrantedAuthority> authorities = SecurityContextHolder.getContext()
                .getAuthentication()
                .getAuthorities();
        
        for (Role role : roles) {
            if (authorities.contains(new SimpleGrantedAuthority("ROLE_" + role.name()))) {
                return true;
            }
        }
        return false;
    }

    public static boolean hasAllRoles(Role... roles) {
        Collection<? extends GrantedAuthority> authorities = SecurityContextHolder.getContext()
                .getAuthentication()
                .getAuthorities();
        
        for (Role role : roles) {
            if (!authorities.contains(new SimpleGrantedAuthority("ROLE_" + role.name()))) {
                return false;
            }
        }
        return true;
    }

    public static Set<Role> getCurrentUserRoles() {
        Collection<? extends GrantedAuthority> authorities = SecurityContextHolder.getContext()
                .getAuthentication()
                .getAuthorities();
        
        return authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .filter(authority -> authority.startsWith("ROLE_"))
                .map(authority -> authority.substring(5)) // Remove "ROLE_" prefix
                .map(Role::valueOf)
                .collect(Collectors.toSet());
    }

    public static String getCurrentUserEmail() {
        return SecurityContextHolder.getContext().getAuthentication().getName();
    }

    public static UUID getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof CustomUserDetailsService.CustomUserDetails) {
            return ((CustomUserDetailsService.CustomUserDetails) principal).getId();
        }
        throw new IllegalStateException("Current user is not an instance of CustomUserDetails");
    }

    public static boolean isAuthenticated() {
        return SecurityContextHolder.getContext().getAuthentication().isAuthenticated();
    }
}