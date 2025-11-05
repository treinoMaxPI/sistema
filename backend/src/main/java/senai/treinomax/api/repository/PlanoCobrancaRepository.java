package senai.treinomax.api.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import senai.treinomax.api.model.PlanoCobranca;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PlanoCobrancaRepository extends JpaRepository<PlanoCobranca, UUID> {

    List<PlanoCobranca> findByUsuarioId(UUID usuarioId);

    List<PlanoCobranca> findByPlanoId(UUID planoId);

    List<PlanoCobranca> findByPago(Boolean pago);

    List<PlanoCobranca> findByMesReferencia(YearMonth mesReferencia);

    Optional<PlanoCobranca> findByUsuarioIdAndMesReferencia(UUID usuarioId, YearMonth mesReferencia);

    List<PlanoCobranca> findByDataVencimentoBeforeAndPagoFalse(LocalDate data);

    List<PlanoCobranca> findByDataVencimentoBetween(LocalDate inicio, LocalDate fim);

    @Query("SELECT pc FROM PlanoCobranca pc WHERE pc.usuario.id = :usuarioId AND pc.pago = false ORDER BY pc.dataVencimento ASC")
    List<PlanoCobranca> findCobrancasPendentesPorUsuario(@Param("usuarioId") UUID usuarioId);

    @Query("SELECT SUM(pc.valorCentavos) FROM PlanoCobranca pc WHERE pc.pago = true AND pc.mesReferencia = :mesReferencia")
    Optional<Long> sumValorRecebidoPorMes(@Param("mesReferencia") YearMonth mesReferencia);

    @Query("SELECT COUNT(pc) FROM PlanoCobranca pc WHERE pc.pago = false AND pc.dataVencimento < :dataAtual")
    Long countCobrancasVencidas(@Param("dataAtual") LocalDate dataAtual);

    @Modifying(clearAutomatically = true)
    @Query("UPDATE PlanoCobranca pc SET pc.pago = true, pc.dataPagamento = :dataPagamento WHERE pc.id = :cobrancaId")
    void marcarComoPago(@Param("cobrancaId") UUID cobrancaId, @Param("dataPagamento") LocalDate dataPagamento);

    @Modifying(clearAutomatically = true)
    @Query("UPDATE PlanoCobranca pc SET pc.valorCentavos = :valorCentavos WHERE pc.id = :cobrancaId")
    void atualizarValor(@Param("cobrancaId") UUID cobrancaId, @Param("valorCentavos") Integer valorCentavos);

    @Query("SELECT pc FROM PlanoCobranca pc WHERE pc.plano.id = :planoId AND pc.mesReferencia = :mesReferencia")
    List<PlanoCobranca> findByPlanoAndMes(@Param("planoId") UUID planoId, @Param("mesReferencia") YearMonth mesReferencia);

    @Query("""
        SELECT pc
        FROM PlanoCobranca pc
        WHERE pc.pago = false
        AND pc.inadimplenciaProcessada = false
        AND pc.dataVencimento < :dataAtual
        ORDER BY pc.dataVencimento ASC
    """)
    Page<PlanoCobranca> findVencidasNaoProcessadas(
        @Param("dataAtual") LocalDate dataAtual,
        Pageable pageable
    );

    @Query("""
        SELECT pc
        FROM PlanoCobranca pc
        WHERE pc.pago = true
        AND pc.proximaCobrancaGerada = false
        AND pc.dataVencimento < :dataAtual
        ORDER BY pc.dataVencimento ASC
    """)
    Page<PlanoCobranca> findPagasComProximaNaoGerada(
        @Param("dataAtual") LocalDate dataAtual,
        Pageable pageable
    );
    @Query("""
        SELECT pc
        FROM PlanoCobranca pc
        JOIN FETCH pc.usuario u
        JOIN FETCH pc.plano p
        ORDER BY pc.dataCriacao DESC
    """)
    List<PlanoCobranca> findAllWithUsuarioAndPlano();
}