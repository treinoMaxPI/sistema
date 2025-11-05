package senai.treinomax.api.jobs;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.repository.TarefasExecutadasRepository;
import senai.treinomax.api.model.TarefaExecutada;
import senai.treinomax.api.model.TarefaExecutada.TarefaTipo;
import senai.treinomax.api.service.PlanoUsuarioEventosService;

@Component
@Slf4j
public class VerificacaoMensalPlanosJob {

    @Autowired
    private PlanoUsuarioEventosService planoUsuarioEventosService;

    @Autowired
    private TarefasExecutadasRepository tarefasExecutadasRepository;

    @Scheduled(fixedDelay = 30 * 60 * 1000)
    public void tarefaComIntervaloFixo() {
        LocalDateTime diaHoraExecucao = LocalDateTime.now(ZoneId.of("America/Sao_Paulo"));
        LocalDate diaExecucao = diaHoraExecucao.toLocalDate();

        boolean jaExecutouHoje = tarefasExecutadasRepository.existsByTipoAndDiaExecucaoAndSucessoIsTrue(
            TarefaTipo.MENSAL_VERIFICAR_PLANOS,
            diaExecucao
        );
        if (jaExecutouHoje) {
            log.info("Tarefa mensal já executada em {}. Pulando execução.", diaExecucao);
            return;
        }

        log.info("[JOB] Iniciando tarefa MENSAL_VERIFICAR_PLANOS às {}", diaHoraExecucao);
        TarefaExecutada tarefa = TarefaExecutada.builder()
            .dataHoraExecucao(diaHoraExecucao)
            .diaExecucao(diaExecucao)
            .tipo(TarefaTipo.MENSAL_VERIFICAR_PLANOS)
        .build(); 
        
        try {
            planoUsuarioEventosService.executarCicloMensal();
            tarefa.setSucesso(true);
            log.info("[JOB] Tarefa MENSAL_VERIFICAR_PLANOS concluída com sucesso.");
        } catch (Exception e) {
            log.error("Erro ao processar tarefas mensais", e);
            tarefa.setSucesso(false);
            tarefa.setMensagemErro(e.getMessage());
        } finally {
            this.tarefasExecutadasRepository.save(tarefa);
        }
    }

}

