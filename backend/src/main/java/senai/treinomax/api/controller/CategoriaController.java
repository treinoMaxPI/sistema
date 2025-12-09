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
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.CategoriaRequest;
import senai.treinomax.api.dto.response.CategoriaResponse;
import senai.treinomax.api.model.Categoria;
import senai.treinomax.api.service.CategoriaService;

@RestController
@RequestMapping("/api/categorias")
@RequiredArgsConstructor
@Slf4j
public class CategoriaController {

    private final CategoriaService categoriaService;

    private CategoriaResponse toCategoriaResponse(Categoria categoria) {
        return new CategoriaResponse(
                categoria.getId(),
                categoria.getNome(),
                categoria.getPlanos());
    }

    private final UsuarioService usuarioService;

    @PostMapping
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<CategoriaResponse> criar(@Valid @RequestBody CategoriaRequest categoria) {
        log.warn("Recebendo requisição para criar categoria");

        String userEmail = SecurityUtils.getCurrentUserEmail();
        var usuario = usuarioService.buscarPorEmail(userEmail);
        UUID usuarioId = usuario.getId();

        Categoria salva = categoriaService.salvar(categoria, usuarioId);

        CategoriaResponse categoriaResponse = toCategoriaResponse(salva);
        return ResponseEntity.status(HttpStatus.CREATED).body(categoriaResponse);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<CategoriaResponse> buscarPorId(@PathVariable String id) {
        log.warn("Recebendo requisição para buscar categoria {}", id);
        Categoria categoria = categoriaService.buscarPorId(id);
        CategoriaResponse categoriaResponse = toCategoriaResponse(categoria);
        return ResponseEntity.ok(categoriaResponse);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<List<CategoriaResponse>> listarTodas() {
        log.warn("Recebendo requisição para listar todas as categorias");
        List<Categoria> categorias = categoriaService.listarTodas();
        List<CategoriaResponse> categoriaResponses = categorias.stream()
                .map(this::toCategoriaResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(categoriaResponses);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<CategoriaResponse> atualizar(@PathVariable String id,
            @Valid @RequestBody CategoriaRequest categoria) {
        log.warn("Recebendo requisição para atualizar categoria {}", id);

        Categoria atualizada = categoriaService.atualizar(id, categoria);

        return ResponseEntity.ok(toCategoriaResponse(atualizada));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Void> deletar(@PathVariable String id) {
        log.warn("Recebendo requisição para deletar categoria {}", id);
        categoriaService.deletarPorId(id);
        return ResponseEntity.noContent().build();
    }
}
