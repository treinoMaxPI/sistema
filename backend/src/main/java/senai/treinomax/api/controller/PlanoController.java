package senai.treinomax.api.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.auth.model.Role;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.CriarPlanoRequest;
import senai.treinomax.api.dto.request.AtualizarPlanoRequest;
import senai.treinomax.api.dto.response.MeuPlanoResponse;
import senai.treinomax.api.dto.response.PlanoResponse;
import senai.treinomax.api.model.Plano;
import senai.treinomax.api.service.PlanoService;
import senai.treinomax.api.service.PlanoUsuarioService;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/planos")
@RequiredArgsConstructor
@Slf4j
public class PlanoController {

    private final PlanoService planoService;
    private final UsuarioService usuarioService;
    private final PlanoUsuarioService planoUsuarioService;

    private PlanoResponse toPlanoResponse(Plano plano) {
        return new PlanoResponse(
                plano.getId(),
                plano.getNome(),
                plano.getDescricao(),
                plano.getAtivo(),
                plano.getPrecoCentavos());
    }

    private MeuPlanoResponse toMeuPlanoResponse(Plano plano, String proximoPlanoNome) {
        return new MeuPlanoResponse(
                plano.getId(),
                plano.getNome(),
                plano.getDescricao(),
                plano.getAtivo(),
                plano.getPrecoCentavos(),
                proximoPlanoNome);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PlanoResponse> criarPlano(@Valid @RequestBody CriarPlanoRequest request) {
        log.info("Recebida solicitação para criar plano: {}", request.getNome());

        String userEmail = SecurityUtils.getCurrentUserEmail();
        var usuario = usuarioService.buscarPorEmail(userEmail);
        UUID usuarioId = usuario.getId();

        Plano plano = planoService.criarPlano(request, usuarioId);
        PlanoResponse response = toPlanoResponse(plano);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<List<PlanoResponse>> listarPlanos(@RequestParam(defaultValue = "true") Boolean ativos) {
        log.info("Recebida solicitação para listar planos (ativos: {})", ativos);

        List<Plano> planos;
        if (!ativos && SecurityUtils.hasRole(Role.ADMIN)) {
            planos = planoService.listarTodosPlanos();
        } else {
            planos = planoService.listarPlanosAtivos();
        }

        List<PlanoResponse> response = planos.stream()
                .map(this::toPlanoResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<PlanoResponse> buscarPlanoPorId(@PathVariable UUID id) {
        log.info("Recebida solicitação para buscar plano por ID: {}", id);

        Plano plano = planoService.buscarPorId(id);
        PlanoResponse response = toPlanoResponse(plano);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PlanoResponse> atualizarPlano(
            @PathVariable UUID id,
            @Valid @RequestBody AtualizarPlanoRequest request) {
        log.info("Recebida solicitação para atualizar plano: {}", id);

        Plano plano = planoService.atualizarPlano(id, request);
        PlanoResponse response = toPlanoResponse(plano);
        return ResponseEntity.ok(response);
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

    @PostMapping("/{id}/escolher")
    @PreAuthorize("hasAnyRole('CUSTOMER')")
    public ResponseEntity<Void> escolherPlano(@PathVariable UUID id) {
        log.info("Recebida solicitação para escolher plano: {}", id);

        String userEmail = SecurityUtils.getCurrentUserEmail();
        Usuario usuario = usuarioService.buscarPorEmail(userEmail);
        UUID usuarioId = usuario.getId();

        planoUsuarioService.atribuirPlanoAoUsuario(usuarioId, id);

        log.info("Plano {} escolhido com sucesso pelo usuário {}", id, userEmail);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/meu-plano")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<MeuPlanoResponse> obterMeuPlano() {
        log.info("Recebida solicitação para obter plano do usuário logado");

        String userEmail = SecurityUtils.getCurrentUserEmail();
        Usuario usuario = usuarioService.buscarPorEmail(userEmail);
        UUID usuarioId = usuario.getId();

        Plano plano = planoUsuarioService.obterPlanoDoUsuario(usuarioId);
        if (plano == null) {
            return ResponseEntity.noContent().build();
        }
        MeuPlanoResponse response = toMeuPlanoResponse(
                plano,
                usuario.getProximoPlano() == null ? null : usuario.getProximoPlano().getNome());
        return ResponseEntity.ok(response);
    }
}