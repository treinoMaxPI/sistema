package senai.treinomax.api.service;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.model.Aula;
import senai.treinomax.api.repository.AulaRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class AulaService {

    private final AulaRepository aulaRepository;

    /**
     * Salva (cria/atualiza) uma aula.
     */
    @Transactional
    public Aula salvar(Aula aula) {
        if (aula.getId() == null) {
            aula.setId(UUID.randomUUID());
        }
        Aula salva = aulaRepository.save(aula);
        log.info("Aula salva: {}", salva.getId());
        return salva;
    }

    /**
     * Busca uma aula pelo id (String UUID).
     */
    @Transactional(readOnly = true)
    public Aula buscarPorId(String id) {
        UUID uuid;
        try {
            uuid = UUID.fromString(id);
        } catch (IllegalArgumentException ex) {
            log.warn("ID inválido ao buscar aula: {}", id);
            throw new RuntimeException("ID inválido: " + id, ex);
        }
        Optional<Aula> opt = aulaRepository.findById(uuid);
        return opt.orElseThrow(() -> {
            log.warn("Aula não encontrada: {}", id);
            return new RuntimeException("Aula não encontrada: " + id);
        });
    }

    /**
     * Lista todas as aulas.
     */
    @Transactional(readOnly = true)
    public List<Aula> listarTodas() {
        return aulaRepository.findAll();
    }

    /**
     * Deleta uma aula por id.
     */
    @Transactional
    public void deletarPorId(String id) {
        UUID uuid;
        try {
            uuid = UUID.fromString(id);
        } catch (IllegalArgumentException ex) {
            log.warn("ID inválido ao deletar aula: {}", id);
            throw new RuntimeException("ID inválido: " + id, ex);
        }
        if (!aulaRepository.existsById(uuid)) {
            log.warn("Tentativa de deletar aula inexistente: {}", id);
            throw new RuntimeException("Aula não encontrada: " + id);
        }
        aulaRepository.deleteById(uuid);
        log.info("Aula deletada: {}", id);
    }

    /**
     * Armazena imagem de aula em disco em "uploads/aulas" e retorna o path relativo que pode ser exposto pela API.
     * Ex.: /uploads/aulas/{filename}
     */
    public String salvarImagem(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Arquivo vazio");
        }

        try {
            Path uploadDir = Paths.get("uploads", "aulas");
            Files.createDirectories(uploadDir);

            String original = file.getOriginalFilename();
            String ext = extension(original);
            String filename = UUID.randomUUID().toString() + (ext.isEmpty() ? "" : "." + ext);
            Path target = uploadDir.resolve(filename);

            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            String relative = "/uploads/aulas/" + filename;
            log.info("Imagem salva em {}", relative);
            return relative;
        } catch (IOException e) {
            log.error("Erro ao salvar imagem de aula", e);
            throw new RuntimeException("Erro ao salvar imagem", e);
        }
    }

    private String extension(String name) {
        if (name == null) return "";
        int idx = name.lastIndexOf('.');
        if (idx == -1) return "";
        return name.substring(idx + 1);
    }
}