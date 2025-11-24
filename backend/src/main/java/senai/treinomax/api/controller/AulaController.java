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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.model.Aula;
import senai.treinomax.api.service.AulaService;

@RestController
@RequestMapping("/api/aulas")
@RequiredArgsConstructor
@Slf4j
public class AulaController {

    private final AulaService aulaService;

    @PostMapping
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Aula> criar(@Valid @RequestBody Aula aula) {
        log.warn("Recebendo requisição para criar aula");
        Aula salva = aulaService.salvar(aula);
        return ResponseEntity.status(HttpStatus.CREATED).body(salva);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CUSTOMER', 'PERSONAL')")
    public ResponseEntity<Aula> buscarPorId(@PathVariable String id) {
        log.warn("Recebendo requisição para buscar aula {}", id);
        Aula aula = aulaService.buscarPorId(id);
        return ResponseEntity.ok(aula);
    }

    @GetMapping
    public ResponseEntity<List<Aula>> listarTodas() {
        log.warn("Recebendo requisição para listar todas as aulas");
        List<Aula> aulas = aulaService.listarTodas();
        return ResponseEntity.ok(aulas);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<Aula> atualizar(@PathVariable String id,
                                          @Valid @RequestBody Aula aula) {
        log.warn("Recebendo requisição para atualizar aula {}", id);
        aula.setId(UUID.fromString(id));
        Aula atualizada = aulaService.salvar(aula);
        return ResponseEntity.ok(atualizada);
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