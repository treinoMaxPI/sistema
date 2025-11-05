package senai.treinomax.api.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.model.PlanoCobranca;
import senai.treinomax.api.repository.PlanoCobrancaRepository;
import senai.treinomax.api.util.DateUtils;

@Service
@RequiredArgsConstructor
@Slf4j
public class PlanoUsuarioEventosService {
    private static int batchSize = 50; 
    
    private final PlanoCobrancaRepository planoCobrancaRepository;
    private final PlanoUsuarioService planoUsuarioService;

    @Transactional
    public void executarCicloVerificacaoCobranca(LocalDateTime horarioProcessamento) {
        processarInadimplencias(horarioProcessamento);
        gerarNovasCobrancas(horarioProcessamento);
    }

    @Transactional
    public void gerarNovasCobrancas(LocalDateTime now) {
        log.info("Iniciando geração de novas cobranças em {}", now);
        Pageable pageRequest = PageRequest.of(0, batchSize);
        Page<PlanoCobranca> page;
        LocalDate localDateNow = now.toLocalDate();
        do {
            page = planoCobrancaRepository.findPagasComProximaNaoGerada(localDateNow, pageRequest);
            log.info("Processando {} cobranças pagas com próxima não gerada", page.getNumberOfElements());

            for (PlanoCobranca cobranca: page.getContent()) {
                planoUsuarioService.gerarProximaCobranca(cobranca);
            }

            pageRequest = pageRequest.next();
        } while (!page.isLast());
        log.info("Finalizada geração de novas cobranças");
    }

    @Transactional
    public void processarInadimplencias(LocalDateTime now) {
        log.info("Iniciando processamento de inadimplências em {}", now);
        Pageable pageRequest = PageRequest.of(0, batchSize);
        Page<PlanoCobranca> page;
        LocalDate localDateNow = now.toLocalDate();
        do {
            page = planoCobrancaRepository.findVencidasNaoProcessadas(localDateNow, pageRequest);
            log.info("Processando {} cobranças vencidas não processadas", page.getNumberOfElements());
            
            for (PlanoCobranca cobranca: page.getContent()) {
                planoUsuarioService.processarInadimplencia(cobranca);
            }

            pageRequest = pageRequest.next();
        } while (!page.isLast());
        log.info("Finalizado processamento de inadimplências");
    }
    public void pagarCobranca(UUID cobrancaId) {
        log.info("Iniciando registro de pagamento para cobrança id {}", cobrancaId);
        Optional<PlanoCobranca> cobrancaOpt = this.planoCobrancaRepository.findById(cobrancaId);
        if (cobrancaOpt.isEmpty()) {
            log.warn("Cobrança não encontrada: {}", cobrancaId);
            throw new IllegalArgumentException("Cobrança não encontrada: " + cobrancaId);
        }

        PlanoCobranca cobranca = cobrancaOpt.get();
        log.debug("Estado atual da cobrança antes do pagamento: id={}, pago={}, dataPagamento={}",
                cobranca.getId(), cobranca.isPago(), cobranca.getDataPagamento());

        LocalDate pagamentoDate = DateUtils.getCurrentBrazilianLocalDate();
        String usuario = SecurityUtils.getCurrentUserEmail();
        String observacoes = "Marcado como pago manualmente por administrador: " + usuario;

        cobranca.setDataPagamento(pagamentoDate);
        cobranca.setObservacoes(observacoes);
        cobranca.setPago(true);

        log.debug("Atualizando cobrança id {} com dataPagamento={} observacoes={} pago={}",
                cobranca.getId(), pagamentoDate, observacoes, cobranca.isPago());

        try {
            this.planoCobrancaRepository.save(cobranca);
            log.info("Pagamento registrado com sucesso para cobrança id {}", cobrancaId);
        } catch (Exception ex) {
            log.error("Erro ao salvar pagamento para cobrança id {}: {}", cobrancaId, ex.getMessage(), ex);
            throw ex;
        }
    }

}
