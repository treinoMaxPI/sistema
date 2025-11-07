package senai.treinomax.api.auth.service;

import senai.treinomax.api.auth.model.Role;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.Collections;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado com email: " + email));

        return new CustomUserDetails(
                usuario.getId(),
                usuario.getEmail(),
                usuario.getSenha(),
                usuario.getAtivo(),
                getAuthorities(usuario)
        );
    }

    private Collection<? extends GrantedAuthority> getAuthorities(Usuario usuario) {
        if (usuario.getRoles() == null || usuario.getRoles().isEmpty()) {
            // Default role if no roles are assigned
            return Collections.emptyList();
        }
        
        return usuario.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.name()))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public UserDetails loadUserById(UUID id) throws UsernameNotFoundException {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado com ID: " + id));

        return new CustomUserDetails(
                usuario.getId(),
                usuario.getEmail(),
                usuario.getSenha(),
                usuario.getAtivo(),
                getAuthorities(usuario)
        );
    }
    @Data
    public static class CustomUserDetails implements UserDetails {
        private final UUID id;
        private final String username;
        private final String password;
        private final boolean enabled;
        private final Collection<? extends GrantedAuthority> authorities;

        public CustomUserDetails(UUID id, String username, String password, boolean enabled,
                               Collection<? extends GrantedAuthority> authorities) {
            this.id = id;
            this.username = username;
            this.password = password;
            this.enabled = enabled;
            this.authorities = authorities;
        }

        @Override
        public Collection<? extends GrantedAuthority> getAuthorities() {
            return authorities;
        }

        @Override
        public String getPassword() {
            return password;
        }

        @Override
        public String getUsername() {
            return username;
        }

        @Override
        public boolean isAccountNonExpired() {
            return true;
        }

        @Override
        public boolean isAccountNonLocked() {
            return true;
        }

        @Override
        public boolean isCredentialsNonExpired() {
            return true;
        }

        @Override
        public boolean isEnabled() {
            return enabled;
        }
    }
}