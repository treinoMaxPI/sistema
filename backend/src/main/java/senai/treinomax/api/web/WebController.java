package senai.treinomax.api.web;

import senai.treinomax.api.auth.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
@Slf4j
public class WebController {

    private final AuthService authService;

    @Value("${cors.allowed-origins:http://localhost:4200}")
    private String allowedOrigins;

    @GetMapping("/verify-email")
    public String verifyEmail(@RequestParam String token, Model model) {
        log.info("Recebida solicitação de verificação de email via web: {}", token);
        
        try {
            // Verify the email token
            authService.verificarEmail(token);
            
            // Success case
            model.addAttribute("success", true);
            model.addAttribute("message", "Seu email foi verificado com sucesso! Agora você pode fazer login no aplicativo.");
            log.info("Email verificado com sucesso via web para token: {}", token);
            
        } catch (Exception e) {
            // Error case
            model.addAttribute("success", false);
            model.addAttribute("message", "Erro ao verificar email: " + e.getMessage());
            log.warn("Erro ao verificar email via web para token {}: {}", token, e.getMessage());
        }
        
        // Get the first allowed origin for redirection
        String redirectUrl = allowedOrigins.split(",")[0].trim();
        model.addAttribute("redirectUrl", redirectUrl);
        
        return "email-verification-result";
    }
}