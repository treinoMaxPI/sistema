package senai.treinomax.api.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.model.Aula;
import senai.treinomax.api.repository.AulaRepository;
import senai.treinomax.api.repository.CategoriaRepository;


@Service
@RequiredArgsConstructor
@Slf4j
public class AulaService {
    
    private final AulaRepository aulaRepository;
    private final CategoriaRepository categoriaRepository;

    @Transactional
    public Aula salvar(Aula aula) {
        log.warn("Salvando aula: {}", aula);
        return aulaRepository.save(aula);
    }

    @Transactional
    public void deletarPorId(String id) {
        log.warn("Deletando aula por ID: {}", id);
        aulaRepository.deleteById(UUID.fromString(id));
    }

    @Transactional
    public Aula buscarPorId(String id) {
        log.warn("Buscando aula por ID: {}", id);
        return aulaRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new IllegalArgumentException("Aula não encontrada com ID: " + id));
    }

    @Transactional
    public List<Aula> listarTodas() {
        log.warn("Listando todas as aulas");
        return aulaRepository.findAll();
    }

    @Transactional
    public List<Aula> listarPorCategoriaId(String categoriaId) {
        log.warn("Listando aulas por categoria ID: {}", categoriaId);
        return aulaRepository.findByCategoriaId(UUID.fromString(categoriaId));
    }

}
