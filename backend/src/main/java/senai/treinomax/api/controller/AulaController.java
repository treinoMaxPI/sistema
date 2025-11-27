package senai.treinomax.api.controller;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.AulaRequest;
import senai.treinomax.api.dto.response.AulaResponse;
import senai.treinomax.api.dto.response.CategoriaResponse;
import senai.treinomax.api.model.Aula;
import senai.treinomax.api.service.AulaService;

@RestController
@RequestMapping("/api/aulas")
@RequiredArgsConstructor
@Slf4j
public class AulaController {

    private final AulaService aulaService;
    private final UsuarioService usuarioService;

    private AulaResponse toResponse(Aula aula) {
        CategoriaResponse categoriaResponse = new CategoriaResponse(
                aula.getCategoria().getId(),
                aula.getCategoria().getNome(),
                aula.getCategoria().getPlanos());

        return new AulaResponse(
                aula.getId(),
                aula.getTitulo(),
                aula.getDescricao(),
                aula.getBannerUrl(),
                aula.getData(),
                aula.getDuracao(),
                categoriaResponse,
                aula.getUsuarioPersonal() != null ? aula.getUsuarioPersonal().getNome() : null);
    }

    @PostMapping
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<AulaResponse> criar(@Valid @RequestBody AulaRequest request) {
        log.warn("Recebendo requisição para criar aula");
        String email = SecurityUtils.getCurrentUserEmail();
        var usuario = usuarioService.buscarPorEmail(email);

        Aula salva = aulaService.salvar(request, usuario.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(salva));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<AulaResponse> buscarPorId(@PathVariable String id) {
        log.warn("Recebendo requisição para buscar aula {}", id);
        Aula aula = aulaService.buscarPorId(id);
        return ResponseEntity.ok(toResponse(aula));
    }

    @GetMapping
    public ResponseEntity<List<AulaResponse>> listarTodas() {
        log.warn("Recebendo requisição para listar todas as aulas");
        List<Aula> aulas = aulaService.listarTodas();
        List<AulaResponse> responses = aulas.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<AulaResponse> atualizar(@PathVariable String id,
            @Valid @RequestBody AulaRequest request) {
        log.warn("Recebendo requisição para atualizar aula {}", id);
        Aula atualizada = aulaService.atualizar(id, request);
        return ResponseEntity.ok(toResponse(atualizada));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Void> deletar(@PathVariable String id) {
        log.warn("Recebendo requisição para deletar aula {}", id);
        aulaService.deletarPorId(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/upload")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<String> uploadImagem(@RequestParam("file") MultipartFile file) {
        log.warn("Recebendo requisição para upload de imagem de aula");
        String path = aulaService.salvarImagem(file);
        return ResponseEntity.ok(path);
    }
}