package senai.treinomax.api.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import senai.treinomax.api.auth.model.Treino;
import senai.treinomax.api.auth.model.Usuario;

import java.util.List;
import java.util.UUID;

@Repository
public interface TreinoRepository extends JpaRepository<Treino, UUID> {

    @EntityGraph(attributePaths = { "itens", "itens.exercicio", "usuario" })
    List<Treino> findByUsuarioId(UUID usuarioId);

    @EntityGraph(attributePaths = { "itens", "itens.exercicio", "usuario" })
    @Override
    List<Treino> findAll();

    @EntityGraph(attributePaths = { "itens", "itens.exercicio", "usuario" })
    @Override
    java.util.Optional<Treino> findById(UUID id);

    @Query("SELECT DISTINCT t.usuario FROM Treino t WHERE t.usuario IS NOT NULL")
    List<Usuario> findDistinctUsuariosWithTreinos();
}
