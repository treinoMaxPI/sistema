package senai.treinomax.api.auth.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.auth.model.Treino;
import senai.treinomax.api.service.TreinoService;
import senai.treinomax.api.service.ExecucaoTreinoService;
import senai.treinomax.api.auth.model.ExecucaoTreino;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/treino")
@Slf4j
@RequiredArgsConstructor
public class TreinoController {

    private final TreinoService treinoService;
    private final ExecucaoTreinoService execucaoTreinoService;

    @PostMapping
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> create(@RequestBody Map<String, Object> request) {
        try {
            Treino treino = new Treino();
            treino.setNome((String) request.get("nome"));
            treino.setTipoTreino((String) request.get("tipoTreino"));
            treino.setDescricao(request.get("descricao") != null ? (String) request.get("descricao") : null);
            treino.setNivel(request.get("nivel") != null ? (String) request.get("nivel") : null);

            if (request.get("usuarioId") == null) {
                return ResponseEntity.badRequest().body(Map.of("message", "usuarioId é obrigatório"));
            }

            UUID usuarioId = UUID.fromString(request.get("usuarioId").toString());

            // Extrair itens do request
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> itensRequest = (List<Map<String, Object>>) request.get("itens");

            var treinoCriado = treinoService.criarTreino(treino, usuarioId, itensRequest);
            return ResponseEntity.status(HttpStatus.CREATED).body(treinoCriado);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", "ID de usuário inválido: " + e.getMessage()));
        } catch (Exception e) {
            log.error("Erro ao criar treino", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('PERSONAL', 'CUSTOMER')")
    public ResponseEntity<?> getById(@PathVariable UUID id) {
        var treino = treinoService.buscarPorId(id);
        if (treino == null) {
            return ResponseEntity.notFound().build();
        }

        // Customer só pode ver seus próprios treinos
        if (SecurityUtils.hasRole(senai.treinomax.api.auth.model.Role.CUSTOMER)) {
            UUID currentUserId = SecurityUtils.getCurrentUserId();
            if (!treino.getUsuario().getId().equals(currentUserId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
        }

        return ResponseEntity.ok(treino);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('PERSONAL', 'CUSTOMER')")
    public ResponseEntity<?> getAll(@RequestParam(required = false) UUID usuarioId) {
        List<Treino> treinos;
        
        if (usuarioId != null) {
            if (!SecurityUtils.hasRole(senai.treinomax.api.auth.model.Role.PERSONAL)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Acesso negado: apenas Personal pode filtrar por usuário"));
            }
            // Personal pode filtrar por usuário
            treinos = treinoService.listarPorUsuario(usuarioId);
            return ResponseEntity.ok(treinos);
        }
        UUID currentUserId = SecurityUtils.getCurrentUserId();  
        treinos = treinoService.listarPorUsuario(currentUserId);
        return ResponseEntity.ok(treinos);
    }

    @GetMapping("/usuarios-com-treinos")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> getUsuariosComTreinos() {
        try {
            List<senai.treinomax.api.auth.model.Usuario> usuarios = treinoService.listarUsuariosComTreinos();

            List<Map<String, Object>> usuariosResponse = usuarios.stream()
                    .map(usuario -> {
                        Map<String, Object> userMap = new HashMap<>();
                        userMap.put("id", usuario.getId());
                        userMap.put("nome", usuario.getNome());
                        userMap.put("email", usuario.getEmail());
                        return userMap;
                    })
                    .collect(java.util.stream.Collectors.toList());

            return ResponseEntity.ok(usuariosResponse);
        } catch (Exception e) {
            log.error("Erro ao listar usuários com treinos", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> update(@PathVariable UUID id, @RequestBody Map<String, Object> request) {
        try {
            Treino treino = new Treino();
            treino.setNome((String) request.get("nome"));
            treino.setTipoTreino((String) request.get("tipoTreino"));
            treino.setDescricao(request.get("descricao") != null ? (String) request.get("descricao") : null);
            treino.setNivel(request.get("nivel") != null ? (String) request.get("nivel") : null);

            // Extrair itens do request
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> itensRequest = (List<Map<String, Object>>) request.get("itens");

            var treinoAtualizado = treinoService.atualizarTreino(id, treino, itensRequest);
            if (treinoAtualizado == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(treinoAtualizado);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", "ID inválido: " + e.getMessage()));
        } catch (Exception e) {
            log.error("Erro ao atualizar treino", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        boolean deletado = treinoService.deletarTreino(id);
        if (!deletado) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/iniciar")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<?> iniciarTreino(@PathVariable UUID id) {
        try {
            UUID currentUserId = SecurityUtils.getCurrentUserId();
            ExecucaoTreino execucao = execucaoTreinoService.iniciarTreino(id, currentUserId);
            return ResponseEntity.ok(execucao);
        } catch (RuntimeException e) {
            log.error("Erro ao iniciar treino", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/execucao/{execucaoId}/finalizar")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<?> finalizarTreino(@PathVariable UUID execucaoId) {
        try {
            UUID currentUserId = SecurityUtils.getCurrentUserId();
            ExecucaoTreino execucao = execucaoTreinoService.finalizarTreino(execucaoId, currentUserId);
            return ResponseEntity.ok(execucao);
        } catch (RuntimeException e) {
            log.error("Erro ao finalizar treino", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/execucao/ativa")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<?> getExecucaoAtiva() {
        try {
            UUID currentUserId = SecurityUtils.getCurrentUserId();
            var execucao = execucaoTreinoService.buscarExecucaoAtiva(currentUserId);
            if (execucao.isPresent()) {
                return ResponseEntity.ok(execucao.get());
            }
            // Retorna 200 com null ao invés de 404 para indicar que não há execução ativa
            return ResponseEntity.ok(null);
        } catch (Exception e) {
            log.error("Erro ao buscar execução ativa", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/execucao/historico")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<?> getHistorico() {
        try {
            UUID currentUserId = SecurityUtils.getCurrentUserId();
            var historico = execucaoTreinoService.listarHistorico(currentUserId);
            return ResponseEntity.ok(historico);
        } catch (Exception e) {
            log.error("Erro ao buscar histórico", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}
