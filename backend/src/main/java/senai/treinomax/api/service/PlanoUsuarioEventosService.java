package senai.treinomax.api.service;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.model.PlanoCobranca;
import senai.treinomax.api.repository.PlanoCobrancaRepository;
import senai.treinomax.api.repository.PlanoRepository;

@Service
@RequiredArgsConstructor
public class PlanoUsuarioEventosService {
    private static int batchSize = 50; 
    
    private final UsuarioRepository usuarioRepository;
    private final PlanoRepository planoRepository;
    private final PlanoCobrancaRepository planoCobrancaRepository;
    private final PlanoUsuarioService planoUsuarioService;

    @Transactional
    public void executarCicloVerificacaoCobranca(LocalDateTime horarioProcessamento) {
        processarInadimplencias(horarioProcessamento);
        gerarNovasCobrancas(horarioProcessamento);
    }

    public void gerarNovasCobrancas(LocalDateTime now) {

    }

    public void processarInadimplencias(LocalDateTime now) {
        Pageable pageRequest = PageRequest.of(0, batchSize);
        Page<PlanoCobranca> page;
        LocalDate localDateNow = now.toLocalDate();
        do {
            page = planoCobrancaRepository.findVencidasNaoProcessadas(localDateNow, pageRequest);

            for (PlanoCobranca cobranca: page.getContent()) {
                planoUsuarioService.processarInadimplencia(cobranca);
            }

            pageRequest = pageRequest.next();
        } while (!page.isLast());
    }

}
