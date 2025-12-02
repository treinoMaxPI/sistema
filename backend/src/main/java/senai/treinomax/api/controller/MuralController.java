package senai.treinomax.api.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.auth.model.Role;
import senai.treinomax.api.dto.request.AtualizarComunicadoRequest;
import senai.treinomax.api.dto.request.CriarComunicadoRequest;
import senai.treinomax.api.dto.response.ComunicadoResponse;
import senai.treinomax.api.model.Comunicado;
import senai.treinomax.api.service.MuralService;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.stream.Collectors;
import java.io.ByteArrayInputStream;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/api/mural")
@RequiredArgsConstructor
@Slf4j
public class MuralController {

    private final MuralService muralService;
    private final Path uploadDir = Paths.get("uploads");
    private static final long MAX_SIZE_BYTES = 5 * 1024 * 1024L; // 5MB
    private static final int MAX_DIMENSION = 1600; // largura/altura máximas

    private ComunicadoResponse toResponse(Comunicado c) {
        return new ComunicadoResponse(
                c.getId(),
                c.getTitulo(),
                c.getMensagem(),
                c.getPublicado(),
                c.getDataCriacao(),
                c.getImagemUrl()
        );
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','CUSTOMER','PERSONAL')")
    public ResponseEntity<List<ComunicadoResponse>> listar(@RequestParam(defaultValue = "false") boolean all) {
        List<Comunicado> comunicados = (!all || !(SecurityUtils.hasAnyRole(Role.ADMIN, Role.PERSONAL)))
                ? muralService.listarPublicados()
                : muralService.listarTodos();

        return ResponseEntity.ok(
                comunicados.stream().map(this::toResponse).collect(Collectors.toList())
        );
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','PERSONAL')")
    public ResponseEntity<ComunicadoResponse> criar(@Valid @RequestBody CriarComunicadoRequest request) {
        UUID userId = SecurityUtils.getCurrentUserId();
        Comunicado c = muralService.criar(request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(c));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','PERSONAL')")
    public ResponseEntity<ComunicadoResponse> atualizar(
            @PathVariable UUID id,
            @Valid @RequestBody AtualizarComunicadoRequest request) {
        Comunicado c = muralService.atualizar(id, request);
        return ResponseEntity.ok(toResponse(c));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('ADMIN','PERSONAL')")
    public ResponseEntity<Void> alterarStatus(
            @PathVariable UUID id,
            @RequestParam boolean publicado) {
        muralService.alterarStatus(id, publicado);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','PERSONAL')")
    public ResponseEntity<Void> excluir(@PathVariable UUID id) {
        muralService.excluir(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/upload")
    @PreAuthorize("hasAnyRole('ADMIN','PERSONAL')")
    public ResponseEntity<Map<String, String>> uploadImagem(@RequestParam("file") MultipartFile file) {
        try {
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            // Não confiar apenas em content-type; vamos validar pelo conteúdo via ImageIO

            String original = Optional.ofNullable(file.getOriginalFilename()).orElse("imagem");
            String ext = "";
            int dot = original.lastIndexOf('.');
            if (dot >= 0) {
                ext = original.substring(dot).toLowerCase();
            }

            byte[] bytes = file.getBytes();
            BufferedImage img = ImageIO.read(new ByteArrayInputStream(bytes));
            if (img == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("message", "Arquivo de imagem inválido"));
            }

            boolean tooLargeBytes = file.getSize() > MAX_SIZE_BYTES;
            boolean tooLargeDims = img.getWidth() > MAX_DIMENSION || img.getHeight() > MAX_DIMENSION;

            String stored;
            Path target;

            if (tooLargeBytes || tooLargeDims) {
                // Redimensiona mantendo proporção para caber em MAX_DIMENSION
                double scale = 1.0;
                int maxSide = Math.max(img.getWidth(), img.getHeight());
                if (maxSide > MAX_DIMENSION) {
                    scale = (double) MAX_DIMENSION / (double) maxSide;
                }
                int newW = (int) Math.round(img.getWidth() * scale);
                int newH = (int) Math.round(img.getHeight() * scale);
                BufferedImage scaled = new BufferedImage(newW, newH, BufferedImage.TYPE_INT_RGB);
                Graphics2D g2d = scaled.createGraphics();
                g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
                g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
                g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                g2d.drawImage(img, 0, 0, newW, newH, null);
                g2d.dispose();

                // Sempre grava como JPG após redimensionar
                stored = UUID.randomUUID() + ".jpg";
                target = uploadDir.resolve(stored);
                ImageIO.write(scaled, "jpg", target.toFile());
            } else {
                // Grava original
                stored = UUID.randomUUID() + (ext.isEmpty() ? ".jpg" : ext);
                target = uploadDir.resolve(stored);
                Files.write(target, bytes);
            }

            String url = ServletUriComponentsBuilder.fromCurrentContextPath()
                    .path("/api/mural/uploads/")
                    .path(stored)
                    .toUriString();
            return ResponseEntity.ok(Map.of("url", url));
        } catch (Exception e) {
            log.error("Falha no upload da imagem", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Erro ao enviar imagem"));
        }
    }

    @GetMapping("/uploads/{filename}")
    public ResponseEntity<Resource> obterImagem(@PathVariable String filename) {
        try {
            Path target = uploadDir.resolve(filename);
            if (!Files.exists(target)) {
                return ResponseEntity.notFound().build();
            }
            Resource resource = new FileSystemResource(target.toFile());
            MediaType mediaType = MediaType.IMAGE_JPEG;
            String lower = filename.toLowerCase();
            if (lower.endsWith(".png")) mediaType = MediaType.IMAGE_PNG;
            if (lower.endsWith(".gif")) mediaType = MediaType.IMAGE_GIF;
            return ResponseEntity.ok().contentType(mediaType).body(resource);
        } catch (Exception e) {
            log.error("Falha ao obter imagem", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}