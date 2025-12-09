package senai.treinomax.api.jobs;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import senai.treinomax.api.auth.repository.TarefasExecutadasRepository;
import senai.treinomax.api.model.TarefaExecutada;
import senai.treinomax.api.model.TarefaExecutada.TarefaTipo;
import senai.treinomax.api.service.PlanoUsuarioEventosService;

@ExtendWith(MockitoExtension.class)
class VerificacaoCobrancaPlanosJobTest {

    @Mock
    private PlanoUsuarioEventosService planoUsuarioEventosService;

    @Mock
    private TarefasExecutadasRepository tarefasExecutadasRepository;

    @InjectMocks
    private VerificacaoCobrancaPlanosJob job;

    @Test
    void tarefaComIntervaloFixo_ShouldExecute_WhenNotExecutedToday() {
        when(tarefasExecutadasRepository.existsByTipoAndDiaExecucaoAndSucessoIsTrue(
                eq(TarefaTipo.MENSAL_VERIFICAR_PLANOS), any(LocalDate.class)))
                .thenReturn(false);

        job.tarefaComIntervaloFixo();

        verify(planoUsuarioEventosService, times(1)).executarCicloVerificacaoCobranca(any(LocalDateTime.class));
        verify(tarefasExecutadasRepository, times(1)).save(any(TarefaExecutada.class));
    }

    @Test
    void tarefaComIntervaloFixo_ShouldSkip_WhenAlreadyExecutedToday() {
        when(tarefasExecutadasRepository.existsByTipoAndDiaExecucaoAndSucessoIsTrue(
                eq(TarefaTipo.MENSAL_VERIFICAR_PLANOS), any(LocalDate.class)))
                .thenReturn(true);

        job.tarefaComIntervaloFixo();

        verify(planoUsuarioEventosService, never()).executarCicloVerificacaoCobranca(any(LocalDateTime.class));
        verify(tarefasExecutadasRepository, never()).save(any(TarefaExecutada.class));
    }

    @Test
    void tarefaComIntervaloFixo_ShouldHandleException_WhenServiceFails() {
        when(tarefasExecutadasRepository.existsByTipoAndDiaExecucaoAndSucessoIsTrue(
                eq(TarefaTipo.MENSAL_VERIFICAR_PLANOS), any(LocalDate.class)))
                .thenReturn(false);

        doThrow(new RuntimeException("Service error")).when(planoUsuarioEventosService)
                .executarCicloVerificacaoCobranca(any(LocalDateTime.class));

        job.tarefaComIntervaloFixo();

        verify(planoUsuarioEventosService, times(1)).executarCicloVerificacaoCobranca(any(LocalDateTime.class));
        verify(tarefasExecutadasRepository, times(1)).save(any(TarefaExecutada.class));
    }

    @Test
    void forcarVerificacaoCobranca_ShouldRunImmediately_WhenNoSuccessfulTask() {
        when(tarefasExecutadasRepository
                .findFirstByTipoAndSucessoTrueOrderByDataHoraExecucaoDesc(TarefaTipo.MENSAL_VERIFICAR_PLANOS))
                .thenReturn(Optional.empty());

        when(tarefasExecutadasRepository.existsByTipoAndDiaExecucaoAndSucessoIsTrue(
                eq(TarefaTipo.MENSAL_VERIFICAR_PLANOS), any(LocalDate.class)))
                .thenReturn(false);

        job.forcarVerificacaoCobranca();

        verify(planoUsuarioEventosService, times(1)).executarCicloVerificacaoCobranca(any(LocalDateTime.class));
    }

    @Test
    void forcarVerificacaoCobranca_ShouldMarkPreviousAsFailedAndRerun_WhenSuccessfulTaskExists() {
        TarefaExecutada previousTask = new TarefaExecutada();
        previousTask.setId(java.util.UUID.randomUUID());
        previousTask.setSucesso(true);
        previousTask.setDataHoraExecucao(LocalDateTime.now());

        when(tarefasExecutadasRepository
                .findFirstByTipoAndSucessoTrueOrderByDataHoraExecucaoDesc(TarefaTipo.MENSAL_VERIFICAR_PLANOS))
                .thenReturn(Optional.of(previousTask));

        when(tarefasExecutadasRepository.existsByTipoAndDiaExecucaoAndSucessoIsTrue(
                eq(TarefaTipo.MENSAL_VERIFICAR_PLANOS), any(LocalDate.class)))
                .thenReturn(false);

        job.forcarVerificacaoCobranca();

        verify(tarefasExecutadasRepository).save(previousTask);
        verify(planoUsuarioEventosService, times(1)).executarCicloVerificacaoCobranca(any(LocalDateTime.class));
    }
}
