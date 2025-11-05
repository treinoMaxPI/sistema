package senai.treinomax.api.web;

import senai.treinomax.api.auth.service.AuthService;
import senai.treinomax.api.dto.response.PlanoCobrancaAdminResponse;
import senai.treinomax.api.jobs.VerificacaoCobrancaPlanosJob;
import senai.treinomax.api.repository.PlanoCobrancaRepository;
import senai.treinomax.api.service.PlanoUsuarioEventosService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
@Slf4j
public class WebController {

    private final PlanoUsuarioEventosService planoUsuarioEventosService;
    private final VerificacaoCobrancaPlanosJob cobrancaPlanosJob; 
    private final AuthService authService;
    private final PlanoCobrancaRepository planoCobrancaRepository;

    @Value("${cors.allowed-origins:http://localhost:4200}")
    private String allowedOrigins;

    @GetMapping("/verify-email")
    public String verifyEmail(@RequestParam String token, Model model) {
        log.info("Recebida solicitação de verificação de email via web: {}", token);

        try {
            authService.verificarEmail(token);
            model.addAttribute("success", true);
            model.addAttribute("message",
                    "Seu email foi verificado com sucesso! Agora você pode fazer login no aplicativo.");
            log.info("Email verificado com sucesso via web para token: {}", token);

        } catch (Exception e) {

            model.addAttribute("success", false);
            model.addAttribute("message", "Erro ao verificar email: " + e.getMessage());
            log.warn("Erro ao verificar email via web para token {}: {}", token, e.getMessage());
        }
        String redirectUrl = allowedOrigins.split(",")[0].trim();
        model.addAttribute("redirectUrl", redirectUrl);
        return "email-verification-result";
    }

    @GetMapping("/admin-login")
    public String adminLoginPage() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            return "redirect:/admin/planos-cobrancas";
        }
        return "admin-login";
    }

    @GetMapping("/admin/planos-cobrancas")
    @PreAuthorize("hasRole('ADMIN')")
    public String listarPlanosCobrancas(Model model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        try {
            List<PlanoCobrancaAdminResponse> cobrancas = planoCobrancaRepository
                    .findAllWithUsuarioAndPlano()
                    .stream()
                    .map(PlanoCobrancaAdminResponse::fromEntity)
                    .collect(Collectors.toList());

            model.addAttribute("cobrancas", cobrancas);
            model.addAttribute("totalCobrancas", cobrancas.size());
            model.addAttribute("adminUsername", username);

            return "admin-planos-cobrancas";

        } catch (Exception e) {
            log.error("Erro ao buscar cobranças", e);
            model.addAttribute("error", "Erro ao carregar dados");
            return "admin-planos-cobrancas";
        }
    }

    @PostMapping("/admin/pagar-cobranca")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> pagarCobranca(@RequestParam String cobrancaId, Model model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        try {
            System.out.println("Ação: Pagar cobrança - ID: " + cobrancaId + " por usuário: " + username);
            this.planoUsuarioEventosService.pagarCobranca(UUID.fromString(cobrancaId));
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Erro ao processar pagamento da cobrança: {}", cobrancaId, e);
            model.addAttribute("error", "Erro ao processar pagamento");
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/admin/forcar-verificacao")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> forcarVerificacaoCobranca(Model model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        try {
            System.out.println("Ação: Forçar verificação de cobranças por usuário: " + username);
            cobrancaPlanosJob.forcarVerificacaoCobranca();
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Erro ao forçar verificação de cobranças", e);
            model.addAttribute("error", "Erro ao forçar verificação");
            return ResponseEntity.badRequest().build();
        }
    }
}