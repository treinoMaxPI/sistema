package senai.treinomax.api.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import senai.treinomax.api.auth.model.ExecucaoTreino;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ExecucaoTreinoRepository extends JpaRepository<ExecucaoTreino, UUID> {

    @EntityGraph(attributePaths = { "treino", "usuario" })
    List<ExecucaoTreino> findByUsuarioIdOrderByDataInicioDesc(UUID usuarioId);

    @EntityGraph(attributePaths = { "treino", "usuario" })
    @Query("SELECT e FROM ExecucaoTreino e WHERE e.usuario.id = :usuarioId AND e.finalizada = false ORDER BY e.dataInicio DESC")
    List<ExecucaoTreino> findByUsuarioIdAndFinalizadaFalseOrderByDataInicioDesc(@Param("usuarioId") UUID usuarioId);

    @EntityGraph(attributePaths = { "treino", "usuario" })
    @Query("SELECT e FROM ExecucaoTreino e WHERE e.usuario.id = :usuarioId AND e.treino.id = :treinoId AND e.finalizada = false")
    Optional<ExecucaoTreino> findExecucaoAtivaByUsuarioAndTreino(@Param("usuarioId") UUID usuarioId, @Param("treinoId") UUID treinoId);

    @EntityGraph(attributePaths = { "treino", "usuario" })
    List<ExecucaoTreino> findByUsuarioIdAndFinalizadaTrueOrderByDataFimDesc(UUID usuarioId);

    @EntityGraph(attributePaths = { "treino", "usuario" })
    @Query("SELECT e FROM ExecucaoTreino e WHERE e.id = :id")
    Optional<ExecucaoTreino> findByIdWithRelations(@Param("id") UUID id);
}

