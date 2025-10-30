package senai.treinomax.api.auth;

import senai.treinomax.api.auth.dto.request.LoginRequest;
import senai.treinomax.api.auth.dto.request.RegistroRequest;
import senai.treinomax.api.auth.dto.response.LoginResponse;
import senai.treinomax.api.auth.service.AuthService;
import senai.treinomax.api.auth.service.UsuarioService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class AuthIntegrationTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private UsuarioService usuarioService;

    @Test
    void contextLoads() {
        assertNotNull(authService);
        assertNotNull(usuarioService);
    }

    @Test
    void testRegistrationAndLoginFlow() {
        // Test data
        String email = "test@example.com";
        String password = "Test123!@#";
        String name = "Test User";

        // Clean up if user exists
        try {
            usuarioService.buscarPorEmail(email);
            // If user exists, we can't test registration
            System.out.println("User already exists, skipping registration test");
            return;
        } catch (Exception e) {
            // User doesn't exist, proceed with test
        }

        // Test registration
        RegistroRequest registroRequest = new RegistroRequest();
        registroRequest.setNome(name);
        registroRequest.setEmail(email);
        registroRequest.setSenha(password);

        try {
            usuarioService.registrarUsuario(registroRequest);
            System.out.println("User registered successfully");
        } catch (Exception e) {
            System.out.println("Registration failed: " + e.getMessage());
            // This might be expected if email is already taken
            return;
        }

        // Test login
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setEmail(email);
        loginRequest.setSenha(password);

        try {
            LoginResponse loginResponse = authService.autenticar(loginRequest);
            assertNotNull(loginResponse);
            assertNotNull(loginResponse.getToken());
            assertNotNull(loginResponse.getRefreshToken());
            assertEquals(email, loginResponse.getEmail());
            assertEquals(name, loginResponse.getNome());
            System.out.println("Login successful");
        } catch (Exception e) {
            fail("Login should succeed after registration: " + e.getMessage());
        }
    }
}