package senai.treinomax.api.controller;

import java.util.List;
import java.util.UUID;

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
import senai.treinomax.api.model.Categoria;
import senai.treinomax.api.service.CategoriaService;

@RestController
@RequestMapping("/api/categorias")
@RequiredArgsConstructor
@Slf4j
public class CategoriaController {

    private final CategoriaService categoriaService;

    private final UsuarioService usuarioService;
    @PostMapping
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Categoria> criar(@Valid @RequestBody Categoria categoria) {
        log.warn("Recebendo requisição para criar categoria");
        

        Categoria salva = categoriaService.salvar(categoria);
        return ResponseEntity.status(HttpStatus.CREATED).body(salva);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<Categoria> buscarPorId(@PathVariable String id) {
        log.warn("Recebendo requisição para buscar categoria {}", id);
        Categoria categoria = categoriaService.buscarPorId(id);
        return ResponseEntity.ok(categoria);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<List<Categoria>> listarTodas() {
        log.warn("Recebendo requisição para listar todas as categorias");
        List<Categoria> categorias = categoriaService.listarTodas();
        return ResponseEntity.ok(categorias);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Categoria> atualizar(@PathVariable String id,
                                               @Valid @RequestBody Categoria categoria) {
        log.warn("Recebendo requisição para atualizar categoria {}", id);

        categoria.setId(UUID.fromString(id));

        Categoria atualizada = categoriaService.salvar(categoria);
        return ResponseEntity.ok(atualizada);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Void> deletar(@PathVariable String id) {
        log.warn("Recebendo requisição para deletar categoria {}", id);
        categoriaService.deletarPorId(id);
        return ResponseEntity.noContent().build();
    }
}
