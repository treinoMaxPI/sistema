package senai.treinomax.api.auth.controller;

import jakarta.validation.Valid;
import senai.treinomax.api.auth.dto.request.*;
import senai.treinomax.api.auth.dto.response.LoginResponse;
import senai.treinomax.api.auth.dto.response.RefreshTokenResponse;
import senai.treinomax.api.auth.model.Exercicio;
import senai.treinomax.api.auth.service.AuthService;
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
        var exercicio = exercicioService.atualizarExercicio(id, request);
        return ResponseEntity.ok(exercicio);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('PERSONAL')")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        exercicioService.deletarExercicio(id);
        return ResponseEntity.noContent().build();
    }
}