package senai.treinomax.api.auth.controller;

import jakarta.validation.Valid;
import senai.treinomax.api.auth.dto.request.*;
import senai.treinomax.api.auth.dto.response.LoginResponse;
import senai.treinomax.api.auth.dto.response.RefreshTokenResponse;
import senai.treinomax.api.auth.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<Void> register(@Valid @RequestBody RegistroRequest registroRequest) {
        log.info("Recebida solicitação de registro para: {}", registroRequest.getEmail());
        
        authService.registrarUsuario(registroRequest);
        
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest loginRequest) {
        log.info("Recebida solicitação de login para: {}", loginRequest.getEmail());
        
        LoginResponse response = authService.autenticar(loginRequest);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(@Valid @RequestBody RecuperacaoSenhaRequest recuperacaoRequest) {
        log.info("Recebida solicitação de recuperação de senha para: {}", recuperacaoRequest.getEmail());
        
        authService.solicitarRecuperacaoSenha(recuperacaoRequest.getEmail());
        
        return ResponseEntity.ok().build();
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(@Valid @RequestBody ResetSenhaRequest resetSenhaRequest) {
        log.info("Recebida solicitação de reset de senha");
        
        authService.resetarSenha(resetSenhaRequest);
        
        return ResponseEntity.ok().build();
    }

    @GetMapping("/verify-email")
    public ResponseEntity<Void> verifyEmail(@RequestParam String token) {
        log.info("Recebida solicitação de verificação de email");
        
        authService.verificarEmail(token);
        
        return ResponseEntity.ok().build();
    }

    @PostMapping("/resend-verification")
    public ResponseEntity<Void> resendVerification(@RequestParam String email) {
        log.info("Recebida solicitação de reenvio de verificação para: {}", email);
        
        authService.reenviarEmailVerificacao(email);
        
        return ResponseEntity.ok().build();
    }

    @PostMapping("/refresh")
    public ResponseEntity<RefreshTokenResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest refreshTokenRequest) {
        log.info("Recebida solicitação de refresh token");
        
        RefreshTokenResponse response = authService.refreshToken(refreshTokenRequest);
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@Valid @RequestBody RefreshTokenRequest refreshTokenRequest) {
        log.info("Recebida solicitação de logout");
        
        authService.logout(refreshTokenRequest.getRefreshToken());
        
        return ResponseEntity.ok().build();
    }

    @PostMapping("/logout-all")
    public ResponseEntity<Void> logoutAll(@RequestParam String email) {
        log.info("Recebida solicitação de logout de todos os dispositivos para: {}", email);
        
        authService.logoutAll(email);
        
        return ResponseEntity.ok().build();
    }
}