package senai.treinomax.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import senai.treinomax.api.auth.model.Role;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;

import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminAuthService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Authenticate user for Thymeleaf admin screens
     * Only allows users with ADMIN role and correct credentials from database
     */
    public boolean authenticate(String username, String password) {
        try {
            // Check if it's a database user with ADMIN role
            Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(username);
            if (usuarioOpt.isPresent()) {
                Usuario usuario = usuarioOpt.get();
                System.out.println("SENHA BATE?");
                System.out.println(password);
                System.out.println(passwordEncoder.matches(password, usuario.getSenha()));
                if (usuario.hasRole(Role.ADMIN) &&
                    usuario.getAtivo() &&
                    usuario.getEmailVerificado() &&
                    passwordEncoder.matches(password, usuario.getSenha())) {
                    log.info("Admin user '{}' authenticated successfully", username);
                    return true;
                }
            }

            log.warn("Failed authentication attempt for username: {}", username);
            return false;

        } catch (Exception e) {
            log.error("Error during admin authentication for user: {}", username, e);
            return false;
        }
    }
}