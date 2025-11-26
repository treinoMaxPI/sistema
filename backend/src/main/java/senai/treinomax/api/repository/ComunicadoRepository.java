package senai.treinomax.api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import senai.treinomax.api.model.Comunicado;

import java.util.List;
import java.util.UUID;

@Repository
public interface ComunicadoRepository extends JpaRepository<Comunicado, UUID> {
    List<Comunicado> findByPublicadoTrueOrderByDataCriacaoDesc();

    @Query("SELECT c FROM Comunicado c ORDER BY c.dataCriacao DESC")
    List<Comunicado> findAllOrderByDataCriacaoDesc();

    @Modifying
    @Query("UPDATE Comunicado c SET c.publicado = :publicado WHERE c.id = :id")
    void atualizarStatusPublicado(@Param("id") UUID id, @Param("publicado") Boolean publicado);
}