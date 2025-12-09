package senai.treinomax.api.auth.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.service.UsuarioService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/usuarios")
@Slf4j
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','PERSONAL')")
    public ResponseEntity<?> listarUsuarios() {
        try {
            List<Usuario> usuarios = usuarioService.listarTodos();

            List<Map<String, Object>> usuariosResponse = usuarios.stream()
                    .map(usuario -> {
                        Map<String, Object> userMap = new HashMap<>();
                        userMap.put("id", usuario.getId());
                        userMap.put("nome", usuario.getNome());
                        userMap.put("email", usuario.getEmail());
                        return userMap;
                    })
                    .collect(Collectors.toList());

            return ResponseEntity.ok(usuariosResponse);
        } catch (Exception e) {
            log.error("Erro ao listar usuários", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/admin/todos")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> listarTodosUsuarios() {
        try {
            List<Usuario> usuarios = usuarioService.listarTodos();
            return ResponseEntity.ok(usuarios);
        } catch (Exception e) {
            log.error("Erro ao listar todos os usuários", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{id}/personal")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> promoverParaPersonal(@PathVariable java.util.UUID id) {
        try {
            usuarioService.promoverParaPersonal(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Erro ao promover usuário para personal", e);
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}
