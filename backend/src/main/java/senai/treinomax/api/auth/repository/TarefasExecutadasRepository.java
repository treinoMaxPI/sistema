package senai.treinomax.api.auth.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import senai.treinomax.api.model.TarefaExecutada;

@Repository
public interface TarefasExecutadasRepository extends JpaRepository<TarefaExecutada, UUID> {
    
    // Verifica se uma tarefa específica já foi executada em um determinado dia
    boolean existsByTipoAndDiaExecucaoAndSucessoIsTrue(TarefaExecutada.TarefaTipo tipo, LocalDate dia);
    
    // Busca todas as execuções de um tipo de tarefa em um dia específico
    // List<TarefaExecutada> findByTipoAndDiaExecucao(TarefaExecutada.TarefaTipo tipo, LocalDate dia);
    
    // Busca a última execução bem-sucedida de um tipo de tarefa
    Optional<TarefaExecutada> findFirstByTipoAndSucessoTrueOrderByDataHoraExecucaoDesc(TarefaExecutada.TarefaTipo tipo);
    
    // Busca todas as execuções de um tipo de tarefa
    List<TarefaExecutada> findByTipoOrderByDataHoraExecucaoDesc(TarefaExecutada.TarefaTipo tipo);
    
    // Busca execuções que falharam em um período
    // @Query("SELECT t FROM TarefasExecutadas t WHERE t.sucesso = false AND t.diaExecucao BETWEEN :inicio AND :fim")
    // List<TarefaExecutada> findFalhasEntreDatas(@Param("inicio") LocalDate inicio, @Param("fim") LocalDate fim);
    
    // Conta quantas vezes uma tarefa foi executada em um mês específico
    // @Query("SELECT COUNT(t) FROM TarefasExecutadas t WHERE t.tipo = :tipo AND YEAR(t.diaExecucao) = :ano AND MONTH(t.diaExecucao) = :mes")
    // long countExecucoesNoMes(@Param("tipo") TarefaExecutada.TarefaTipo tipo, @Param("ano") int ano, @Param("mes") int mes);
}