package senai.treinomax.api.jobs;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;
import senai.treinomax.api.auth.repository.TarefasExecutadasRepository;
import senai.treinomax.api.model.TarefaExecutada;
import senai.treinomax.api.model.TarefaExecutada.TarefaTipo;
import senai.treinomax.api.service.PlanoUsuarioEventosService;

@Component
@Slf4j
public class VerificacaoCobrancaPlanosJob {

    @Autowired
    private PlanoUsuarioEventosService planoUsuarioEventosService;

    @Autowired
    private TarefasExecutadasRepository tarefasExecutadasRepository;

    @Scheduled(fixedDelay = 1 * 60 * 1000)
    protected void tarefaComIntervaloFixo() {
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
            planoUsuarioEventosService.executarCicloVerificacaoCobranca(diaHoraExecucao);
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

    public void forcarVerificacaoCobranca() {
        Optional<TarefaExecutada> tarefaSucedida = this.tarefasExecutadasRepository.findFirstByTipoAndSucessoTrueOrderByDataHoraExecucaoDesc(TarefaTipo.MENSAL_VERIFICAR_PLANOS);
        if (tarefaSucedida.isEmpty()) {
            tarefaComIntervaloFixo();
            return;
        }
        tarefaSucedida.get().setSucesso(false);
        tarefaSucedida.get().setMensagemErro("Foi bem sucedida, porém marcada como nao sucedida para executar outra verificação forçada");
        tarefasExecutadasRepository.save(tarefaSucedida.get());
        this.forcarVerificacaoCobranca();
    }

}

