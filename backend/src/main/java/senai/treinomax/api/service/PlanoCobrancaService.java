package senai.treinomax.api.service;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import senai.treinomax.api.model.PlanoCobranca;
import senai.treinomax.api.repository.PlanoCobrancaRepository;

@Service
@RequiredArgsConstructor
public class PlanoCobrancaService {

    private final PlanoCobrancaRepository planoCobrancaRepository;

    public Page<PlanoCobranca> findCobrancasByUsuarioId(UUID usuarioId, Pageable pageable) {
        return planoCobrancaRepository.findByUsuarioId(usuarioId, pageable);
    }
}