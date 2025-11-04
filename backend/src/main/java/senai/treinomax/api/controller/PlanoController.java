package senai.treinomax.api.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.CriarPlanoRequest;
import senai.treinomax.api.dto.request.AtualizarPlanoRequest;
import senai.treinomax.api.model.Plano;
import senai.treinomax.api.service.PlanoService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/planos")
@RequiredArgsConstructor
@Slf4j
public class PlanoController {

    private final PlanoService planoService;
    private final UsuarioService usuarioService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Plano> criarPlano(@Valid @RequestBody CriarPlanoRequest request) {
        log.info("Recebida solicitação para criar plano: {}", request.getNome());
        
        String userEmail = SecurityUtils.getCurrentUserEmail();
        var usuario = usuarioService.buscarPorEmail(userEmail);
        UUID usuarioId = usuario.getId();
        
        Plano plano = planoService.criarPlano(request, usuarioId);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(plano);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<List<Plano>> listarPlanos(@RequestParam(defaultValue = "true") Boolean ativos) {
        log.info("Recebida solicitação para listar planos (ativos: {})", ativos);
        
        List<Plano> planos;
        if (ativos) {
            planos = planoService.listarPlanosAtivos();
        } else {
            planos = planoService.listarTodosPlanos();
        }
        
        return ResponseEntity.ok(planos);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<Plano> buscarPlanoPorId(@PathVariable UUID id) {
        log.info("Recebida solicitação para buscar plano por ID: {}", id);
        
        Plano plano = planoService.buscarPorId(id);
        return ResponseEntity.ok(plano);
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Plano> atualizarPlano(
            @PathVariable UUID id,
            @Valid @RequestBody AtualizarPlanoRequest request) {
        log.info("Recebida solicitação para atualizar plano: {}", id);
        
        Plano plano = planoService.atualizarPlano(id, request);
        return ResponseEntity.ok(plano);
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> alterarStatusPlano(
            @PathVariable UUID id,
            @RequestParam boolean ativo) {
        log.info("Recebida solicitação para {} plano: {}", ativo ? "ativar" : "desativar", id);
        
        if (ativo) {
            planoService.ativarPlano(id);
        } else {
            planoService.desativarPlano(id);
        }
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/preco")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> atualizarPrecoPlano(
            @PathVariable UUID id,
            @RequestParam Integer precoCentavos) {
        log.info("Recebida solicitação para atualizar preço do plano {} para {} centavos", id, precoCentavos);
        
        planoService.atualizarPreco(id, precoCentavos);
        return ResponseEntity.ok().build();
    }
}