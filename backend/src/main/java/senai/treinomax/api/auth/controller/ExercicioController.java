package senai.treinomax.api.auth.controller;

import senai.treinomax.api.auth.model.Exercicio;
import senai.treinomax.api.service.ExercicioService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/exercicio")
@Slf4j
@RequiredArgsConstructor
public class ExercicioController {

    private final ExercicioService exercicioService;

    @PostMapping
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> create(@RequestBody Exercicio request) {
        var exercicio = exercicioService.criarExercicio(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(exercicio);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> getById(@PathVariable UUID id) {
        var exercicio = exercicioService.buscarPorId(id);
        return ResponseEntity.ok(exercicio);
    }

    @GetMapping
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> getAll() {
        var exercicios = exercicioService.listarTodos();
        return ResponseEntity.ok(exercicios);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> update(@PathVariable UUID id, @RequestBody Exercicio request) {
        try {
            var exercicio = exercicioService.atualizarExercicio(id, request);
            if (exercicio == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(exercicio);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(java.util.Map.of("message", "ID inválido: " + e.getMessage()));
        } catch (Exception e) {
            log.error("Erro ao atualizar exercício", e);
            return ResponseEntity.badRequest().body(java.util.Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        exercicioService.deletarExercicio(id);
        return ResponseEntity.noContent().build();
    }
}