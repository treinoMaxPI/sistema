package senai.treinomax.api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import senai.treinomax.api.model.Plano;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PlanoRepository extends JpaRepository<Plano, UUID> {

    List<Plano> findByAtivoTrue();

    Optional<Plano> findByNome(String nome);

    Boolean existsByNome(String nome);

    List<Plano> findByCriadoPorId(UUID criadoPorId);

    @Modifying
    @Query("UPDATE Plano p SET p.ativo = :ativo WHERE p.id = :planoId")
    void atualizarStatusAtivo(@Param("planoId") UUID planoId, @Param("ativo") Boolean ativo);

    @Modifying
    @Query("UPDATE Plano p SET p.precoCentavos = :precoCentavos WHERE p.id = :planoId")
    void atualizarPreco(@Param("planoId") UUID planoId, @Param("precoCentavos") Integer precoCentavos);

    @Query("SELECT p FROM Plano p WHERE p.precoCentavos BETWEEN :precoMin AND :precoMax AND p.ativo = true")
    List<Plano> findByPrecoRange(@Param("precoMin") Integer precoMin, @Param("precoMax") Integer precoMax);
}